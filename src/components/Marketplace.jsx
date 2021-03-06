
import { useEffect, useState } from "react";
import PriceGetter from "../contracts/PriceGetter.json";
import NBMonCore from "../contracts/NBMonCore.json"
import NBMonMinting from "../contracts/NBMonMinting.json"
import { useMoralis, useNativeBalance } from "react-moralis";
import Birvo from "../BirvoTransparent.png"
import Dranexx from "../DranexxTransparent.png"
import Lamox from "../LamoxPTransparent.png"
import Licorine from "../LicorineTransparent.png"
import Milnas from "../MilnasTransparent.png"
import Pongu from "../PonguTransparent.png"
import Roggo from "../RoggoTransparent.png"
import Schoggi from "../SchoggiTransparent.png"
import Teree from "../TereeTransparent.png"
import Todillo from "../TodilloTransparent.png"

import EggClosed from "../eggclosed.png"
import EggOpenedBack from "../eggopenedback.png"
import EggOpenedFront from "../eggopenedfront.png"

import Confetti from "../confetti.gif"



const TOKEN_CONTRACT_ADDRESS = "0x637bbb29aa81b6a32d309bdf4f53d80881f67c7f";
const PRICEGETTER_CONTRACT_ADDRESS = "0xf21F90585fD99281cefdfdb5A3307082FE62E2B7";

const NBMONMINTING_CONTRACT_ADDRESS = "0xd59916ee966152fab4f3fa23eb8187ee5a4fde18";
const NBMONCORE_CONTRACT_ADDRESS = "0xd798f8c1480f4b2c4ef16c1878a99aa5d2b9bb96";

export const Marketplace = () : React.ReactElement => {
  const { Moralis, isAuthenticated, authenticate, logout } = useMoralis();

  const[bscBalance, setBscBalance] = useState();
  const[bscToUsdBalance, setBscToUsdBalance] = useState();

  const[nftName, setNftName] = useState("");
  const[nftDescription, setNftDescription] = useState("");

  const[healthPar, setHealth] = useState(0);
  const[attackPar, setAttack] = useState(0);
  const[staminaPar, setStamina] = useState(0);

  const[showEgg, setShowEgg] = useState(true);

  const passivesFilter = ["Cold Shield", "Spirits Shield", "Tenacity Shield", "Hammer Shield", "Healing Essence", "Restoring Essence", 
"Last Health Essence", "Phantom Essence", "Energy Banner", "Revitalizing Banner", "Life Banner",
"Charging Banner", "Flaming Sword", "Soul-Shattering Sword", "Avenger Sword", "Jakugan Sword", "Amulet of Haste",
"Widow Amulet", "Supercharged Amulet", "Osur's Amulet", "Enraged Mask", "Mask of Darkness", "Fury Mask", "Baltasar's Mask"];

  const NBMonImages = [Lamox, Licorine, Birvo, Dranexx, Teree, Milnas, Pongu, Schoggi, Roggo, Todillo];

  const[selectedImg, setSelectedImg] = useState("Emily");

  const [NBMons, setNBMons] = useState([]);

  const [mintedNBMon, setMintedNBMon] = useState();
  
  
  const convertImageToBase64 = async (urlImg) => {
    var img = new Image();
    img.src = urlImg;
    await img.decode();
    
    var canvas = document.createElement('canvas'),
      ctx = canvas.getContext('2d');
    
    canvas.height = img.naturalHeight;
    canvas.width = img.naturalWidth;
    ctx.drawImage(img, 0, 0);
    
    var b64 = canvas.toDataURL('image/png');
    return b64;
    };

  const randomIntFromInterval = (min, max) => {
    return Math.floor(Math.random() * (max - min + 1) + min);
  }

  const mintNBMon = async () => {
    /*
    let nbmonimage = "";
    if(selectedImg == "Emily"){
      nbmonimage = await convertImageToBase64(NBMon1);
    }
    else if(selectedImg == "Bobby"){
      nbmonimage = await convertImageToBase64(NBMon2);
    }
    else if(selectedImg == "James"){
      nbmonimage = await convertImageToBase64(NBMon3);
    }
    console.log(nbmonimage);
    const file = new Moralis.File("image.png", {base64 : nbmonimage});
    await file.saveIPFS();

    const imageURL = file.ipfs()
    
    const metadata = {
      "name": nftName,
      "description": nftDescription,
      "image": imageURL
    };

    const metadataFile = new Moralis.File("metadata.json", {base64: btoa(JSON.stringify(metadata))});
    await metadataFile.saveIPFS();

    const metaURL = metadataFile.ipfs();

    console.log(metaURL);
    */

    const abi = NBMonCore.abi;

    const encodedAbiUploadFile = btoa(JSON.stringify(abi))
    const AbiFile = new Moralis.File("NBMonCore.json", { base64: encodedAbiUploadFile })
    const contractAbis = new Moralis.Object("contractAbis");
    contractAbis.set("AbiFile", AbiFile);
    contractAbis.set("Filename", "NBMonCore");
    contractAbis.save();

    const abi2 = NBMonMinting.abi
    const encodedAbiUploadFile2 = btoa(JSON.stringify(abi2))
    const AbiFile2 = new Moralis.File("NBMonMinting.json", { base64: encodedAbiUploadFile2 })
    const contractAbis2 = new Moralis.Object("contractAbis");
    contractAbis2.set("AbiFile", AbiFile2);
    contractAbis2.set("Filename", "NBMonMinting");
    contractAbis2.save();


    const web3 = await Moralis.Web3.enableWeb3();
    const contract = new web3.eth.Contract(abi2, NBMONMINTING_CONTRACT_ADDRESS);
    const contractCore = new web3.eth.Contract(abi, NBMONCORE_CONTRACT_ADDRESS);
    /*
    const totalPrice = 220;
    
    const _finalAttack = attackPar;
    const _finalHealth = healthPar;
    const _finalStamina = staminaPar;
    const _finalURI = metaURL;
    const _finalPrice = web3.utils.toBN(totalPrice * 100000000000);

    console.log(_finalPrice);
    console.log("FINAL PRICE");*/

    /*const receipt = await contract.methods.mintExternal(_finalAttack,
      _finalHealth,
      _finalStamina,
      _finalURI,
      _finalPrice).send({from: web3.currentProvider.selectedAddress, value: _finalPrice});
    */ 
    const randomEggInt = randomIntFromInterval(0, 9007199254740900);
    console.log(randomEggInt);
    const receipt = await contract.methods.mintOrigin(randomEggInt, web3.currentProvider.selectedAddress).send({from: web3.currentProvider.selectedAddress});
    console.log(receipt);

    const NBMonId = parseInt(receipt.events.NBMonMinted.returnValues._nbmonId) - 1;
    console.log(NBMonId);

    const d = await contract.methods.getNBMon(NBMonId).call({from: web3.currentProvider.selectedAddress});
    setShowEgg(false);
    const elementProps = ["Null", "Neutral", "Wind", "Earth", "Water", "Fire", "Nature", "Electric", "Mental", "Digital", "Melee", "Crystal", "Toxic"];
		  const generaProps = ["Lamox", "Licorine", "Birvo", "Dranexx", "Heree", "Milnas", "Piklish", "Prawdek", "Roggo", "Todillo"];
		  const genderProps = ["Male", "Female"];
		  const typeProps = ["Origin", "Wild", "Hybrid"];
		  const rarityProps = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"];
	
		  const gender = genderProps[parseInt(d.nbmonStats[0]) - 1];
		  let rarity = rarityProps[0];
		  const rarityVal = parseInt(d.nbmonStats[1]);
		  if(rarityVal >= 1 && rarityVal <= 650){
			rarity = rarityProps[0];
		  }
		  else if(rarityVal >= 651 && rarityVal <= 850){
			rarity = rarityProps[1];
		  }
		  else if(rarityVal >= 851 && rarityVal <= 950){
			rarity = rarityProps[2];
		  }
		  else if(rarityVal >= 951 && rarityVal <= 990){
			rarity = rarityProps[3];
		  }
		  else if(rarityVal >= 991 && rarityVal <= 999){
			rarity = rarityProps[4];
		  }
		  else if(rarityVal == 1000){
			rarity = rarityProps[5];
		  }
		  const type = typeProps[parseInt(d.nbmonStats[3]) - 1];
		  const genera = generaProps[parseInt(d.nbmonStats[4]) - 1];
      const passives = [passivesFilter[parseInt(d.passives[0])], passivesFilter[parseInt(d.passives[1])]];
	
	
		  const element = (
      <div className="col-md-4 nb-egg-container">
		  <div className="card nbmon-card nb-egg">
      <img src={Confetti} className="confetti-bg"></img>
      <img src={EggOpenedBack} className="egg-opened-back"></img>
		  <img src={NBMonImages[parseInt(d.nbmonStats[4]) - 1]} className="egg-nbmon"></img>
      <img src={EggOpenedFront} className="egg-opened-front"></img>
      <span className="full-egg-description">
		  Gender: {gender} <br/>
		  Rarity: {rarity} <br/>
		  Type: {type} <br/>
		  Genera: {genera} <br/>
      Passives: {passives[0]}, {passives[1]} <br/>
			Inherited Passives: None <br/>
			Inherited Moves: None <br/>
			Potential Stats: <br/>
			<span className="fas fa-briefcase-medical"><i className="fapot">{d.potential[0]}</i></span> Health<br/>
			<span className="fas fa-fire-alt"><i className="fapot">{d.potential[1]}</i></span> Energy<br/>
			<span className="fas fa-khanda"><i className="fapot">{d.potential[2]}</i></span> Attack <br/>
			<span className="fas fa-shield-alt"><i className="fapot">{d.potential[3]}</i></span> Defense<br/>
			<span className="fab fa-gripfire"><i className="fapot">{d.potential[4]}</i></span> Special Attack<br/>
			<span className="fab fa-hive"><i className="fapot">{d.potential[5]}</i></span> Special Defense<br/>
			<span className="fas fa-road"><i className="fapot">{d.potential[6]}</i></span> Speed<br/>
      </span>
		  </div>
		  </div>);

      setMintedNBMon(element);

    getBSCbalance();

    
  };

  const getBSCbalance = async () => {
    const web3 = await Moralis.enableWeb3();
    const abi = PriceGetter.abi
    const contract = new web3.eth.Contract(abi, PRICEGETTER_CONTRACT_ADDRESS);
    const BscToUsdData = await contract.methods.getLatestPrice().call() / 100000000;
    console.log(BscToUsdData);

    const balance = await web3.eth.getBalance(web3.currentProvider.selectedAddress);
    const balanceDeci = web3.utils.fromWei(balance);
    console.log(balanceDeci);

    setBscBalance(balanceDeci);
    setBscToUsdBalance(balanceDeci * BscToUsdData);
  };

  useEffect(() => {
    if(isAuthenticated){
    getBSCbalance();
    }
  console.log("USEFE");
  }, [isAuthenticated]);

    return (
      <div className="marketplace">
        <div className="container">
    {!isAuthenticated ? 
    <button onClick={() => authenticate()}> Authenticate </button>
    
     : <div>
     {showEgg ? <button className="mintAnEgg" onClick={mintNBMon}><img src={EggClosed} className="eggclosed-img"></img></button> : <div className="row">{mintedNBMon}</div>}
     
     </div>}
    </div>  
      </div>
  );
}
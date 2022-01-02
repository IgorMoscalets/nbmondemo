
import { useEffect, useState } from "react";
import PriceGetter from "../contracts/PriceGetter.json";
import NBMonCore from "../contracts/NBMonCore.json"
import { useMoralis, useNativeBalance } from "react-moralis";
import NBMon1 from "../nbmon1.png";
import NBMon2 from "../nbmon2.png";
import NBMon3 from "../nbmon3.png";


const TOKEN_CONTRACT_ADDRESS = "0x36B29994Df52Eb7A58D78F53E274963f24887EfB";
const PRICEGETTER_CONTRACT_ADDRESS = "0xf21F90585fD99281cefdfdb5A3307082FE62E2B7";

export const Marketplace = () : React.ReactElement => {
  const { Moralis, isAuthenticated, authenticate, logout } = useMoralis();

  const[bscBalance, setBscBalance] = useState();
  const[bscToUsdBalance, setBscToUsdBalance] = useState();

  const[nftName, setNftName] = useState("");
  const[nftDescription, setNftDescription] = useState("");

  const[healthPar, setHealth] = useState(0);
  const[attackPar, setAttack] = useState(0);
  const[staminaPar, setStamina] = useState(0);

  const[selectedImg, setSelectedImg] = useState("Emily");

  const [NBMons, setNBMons] = useState([]);
  
  const displayNBMons = async () => {
    setNBMons([]);
    const abi = NBMonCore.abi;
    const web3 = await Moralis.Web3.enableWeb3();
    const contract = new web3.eth.Contract(abi, TOKEN_CONTRACT_ADDRESS);
    const dataArray = await contract.methods.getOwnerNBMonIds(web3.currentProvider.selectedAddress).call({from: web3.currentProvider.selectedAddress});
    
    console.log(dataArray);
    //for(const dogId of dataArray) {
    dataArray.forEach(async (dogId) => {
      const d = await contract.methods.getNBMon(dogId).call({from: web3.currentProvider.selectedAddress});
      const nftTokenURI = d.tokenURI;
      const response = await fetch(nftTokenURI);
      const jsonResponse = await response.json();
      console.log(jsonResponse);

      const nftImageURI = jsonResponse.image;
      console.log(dogId);

      const element = (<div key={dogId} className="col-md-4">
      <div className="card nbmon-card">
      <img src={nftImageURI}></img>
      <div className="nbmonname">{jsonResponse.name}</div> <br/>
      Description: {jsonResponse.description} <br/>
      Health: {d.health} <br/>
      Stamina: {d.stamina} <br/>
      Attack: {d.attack} <br/>
      </div>
      </div>);
      setNBMons(oldArray => [...oldArray, element]);
      console.log(d);
    }); 

  };

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
    const web3 = await Moralis.Web3.enableWeb3();
    const contract = new web3.eth.Contract(abi, TOKEN_CONTRACT_ADDRESS);
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
    const receipt = await contract.methods.mintNBMon("0x619DB0c27484167f18DE31a7756F5F23eEcc5Ca8").send({from: web3.currentProvider.selectedAddress});
    console.log(receipt);


    const dataArray = await contract.methods.getOwnerNBMonIds(web3.currentProvider.selectedAddress).call({from: web3.currentProvider.selectedAddress});
    
    console.log(dataArray);
    //for(const dogId of dataArray) {
    dataArray.forEach(async (NBMonId) => {
      const d = await contract.methods.getNBMon(NBMonId).call({from: web3.currentProvider.selectedAddress});
      //const nftTokenURI = d.tokenURI;
      //const response = await fetch(nftTokenURI);
      //const jsonResponse = await response.json();
      //console.log(jsonResponse);
      //setNBMons(oldArray => [...oldArray, element]);
      console.log(d);
    }); 

    getBSCbalance();
    //displayNBMons();

    
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
    displayNBMons();
    }
  console.log("USEFE");
  }, [isAuthenticated]);

    return (
      <div className="marketplace">
        <div className="container">
    {!isAuthenticated ? 
    <button onClick={() => authenticate()}> Authenticate </button>
    
     : <div>
       <button onClick={() => logout()}>Log Out</button><br/>
     Current Balance: {bscBalance} BNB ({bscToUsdBalance} USD) <br/>
     <button onClick={mintNBMon}>Mint!</button> 
     <div className="row">{NBMons}</div>
     </div>}
    </div>  
      </div>
  );
}
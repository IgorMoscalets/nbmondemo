
import { useEffect, useState } from "react";
import PriceGetter from "../contracts/PriceGetter.json";
import NBMonCore from "../contracts/NBMonCore.json"
import { Marketplace } from "../components"

import Multiselect from 'multiselect-react-dropdown'

import { useMoralis, useNativeBalance } from "react-moralis";
import NBMon1 from "../nbmon1.png";
import NBMon2 from "../nbmon2.png";
import NBMon3 from "../nbmon3.png";
import NBBackground from "../nbmon-background.png"
import { Route, Routes } from "react-router-dom";

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'


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
import Prawdek from "../PrawdekTransparent.png"

const TOKEN_CONTRACT_ADDRESS = "0x637bbb29aa81b6a32d309bdf4f53d80881f67c7f";
const PRICEGETTER_CONTRACT_ADDRESS = "0xf21F90585fD99281cefdfdb5A3307082FE62E2B7";
	
export const Gallery = ({ match }) : React.ReactElement => {

	const { Moralis, isAuthenticated, authenticate, logout } = useMoralis();

	const[bscBalance, setBscBalance] = useState();
	const[bscToUsdBalance, setBscToUsdBalance] = useState();

	const[nftName, setNftName] = useState("");
	const[nftDescription, setNftDescription] = useState("");

	const[elementSelected, setElementSelected] = useState();
	const[generaSelected, setGeneraSelected] = useState();
	const[genderSelected, setGenderSelected] = useState();
	const[typeSelected, setTypeSelected] = useState();
	const[raritySelected, setRaritySelected] = useState();

	const[healthPar, setHealth] = useState(0);
	const[attackPar, setAttack] = useState(0);
	const[staminaPar, setStamina] = useState(0);

	const[selectedImg, setSelectedImg] = useState("Emily");

	const [NBMons, setNBMons] = useState([]);
	const [NBMonsUpdated, setNBMonsUpdated] = useState([]);

	const NBMonImages = [Lamox, Licorine, Birvo, Dranexx, Teree, Milnas, Schoggi, Pongu, Prawdek, Roggo, Todillo];



	const elementFilters = ["Null", "Neutral", "Wind", "Earth", "Water", "Fire", "Nature", "Electric", "Mental", "Digital", "Melee", "Crystal", "Toxic"];
	const elementOptions = elementFilters.map((val, idx) => ({name: val, id: idx}));
	const generaFilters = ["Lamox", "Licorine", "Birvo", "Dranexx", "Heree", "Milnas", "Piklish", "Pongu", "Prawdek", "Roggo", "Todillo"];
	const generaOptions = generaFilters.map((val, idx) => ({name: val, id: idx}));
	const genderFilters = ["Male", "Female"];
	const genderOptions = genderFilters.map((val, idx) => ({name: val, id: idx}));
	const typeFilters = ["Origin", "Wild", "Hybrid"];
	const typeOptions = typeFilters.map((val, idx) => ({name: val, id: idx}));
	const rarityFilters = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"];
	const rarityOptions = rarityFilters.map((val, idx) => ({name: val, id: idx}));

	const arrangeNBMons = (selectedList, listName) => {
		let selectedListNames = [];
		selectedList.forEach((element) => {
			selectedListNames.push(element.name);
		});
		selectedList = selectedListNames;
		console.log(selectedList);
		

		if(listName == "Rarity"){
			if(selectedList.length == 0){
				setRaritySelected(rarityFilters);
			}
			else{
				setRaritySelected(selectedList);
			}
		}
		else if(listName == "Type"){
			if(selectedList.length == 0){
				setTypeSelected(typeFilters);
			}
			else{
				setTypeSelected(selectedList);
			}
		}
		else if(listName == "Gender"){
			if(selectedList.length == 0){
				setGenderSelected(genderFilters);
			}
			else{
				setGenderSelected(selectedList);
			}
		}
		else if(listName == "Genera"){
			if(selectedList.length == 0){
				setGeneraSelected(generaFilters);
			}
			else{
				setGeneraSelected(selectedList);
			}
		}
		console.log(selectedList);
		//let newArr = NBMons;
		
		//for(let i = 0; i < newArr.length; i++){
		//	if(newArr[i]._rarity != "Common"){newArr[i]._hidden = true;}
	//	}
	//	console.log(newArr);
	};

	useEffect(() => {
		console.log(generaSelected + genderSelected + typeSelected + raritySelected);

		let newArr = NBMons;
		setNBMons([]);
		
		for(let i = 0; i < newArr.length; i++){
			if(!raritySelected.includes(newArr[i]._rarity)){
				newArr[i]._hidden = true;
			}
			else if(!typeSelected.includes(newArr[i]._type)){
				newArr[i]._hidden = true;
			}
			else if(!genderSelected.includes(newArr[i]._gender)){
				newArr[i]._hidden = true;
			}
			else if(!generaSelected.includes(newArr[i]._genera)){
				newArr[i]._hidden = true;
			}
			else{
				newArr[i]._hidden = false;
			}
			setNBMons(oldArray => [...oldArray, newArr[i]]);
		}
		console.log(newArr);


	}, [raritySelected, typeSelected, genderSelected, generaSelected]);

	const displayNBMons = async () => {
		setGeneraSelected(generaFilters);
		setTypeSelected(typeFilters);
		setGenderSelected(genderFilters);
		setRaritySelected(rarityFilters);

		setNBMons([]);
		const abi = NBMonCore.abi;
		const web3 = await Moralis.Web3.enableWeb3();
		const contract = new web3.eth.Contract(abi, TOKEN_CONTRACT_ADDRESS);
		const dataArray = await contract.methods.getOwnerNBMonIds(web3.currentProvider.selectedAddress).call({from: web3.currentProvider.selectedAddress});
		
		console.log(dataArray);
		//for(const dogId of dataArray) {
		for(let i = 0; i < dataArray.length; i++){
			const dogId = dataArray[i];
		  const d = await contract.methods.getNBMon(dogId).call({from: web3.currentProvider.selectedAddress});
		  //const nftTokenURI = d.tokenURI;
		  //const response = await fetch(nftTokenURI);
		  //const jsonResponse = await response.json();
		  //console.log(jsonResponse);
	
		  //const nftImageURI = jsonResponse.image;
		  console.log(dogId);
		  const elementProps = ["Null", "Neutral", "Wind", "Earth", "Water", "Fire", "Nature", "Electric", "Mental", "Digital", "Melee", "Crystal", "Toxic"];
		  const generaProps = ["Lamox", "Licorine", "Birvo", "Dranexx", "Heree", "Milnas", "Piklish", "Pongu", "Prawdek", "Roggo", "Todillo"];
		  const genderProps = ["Male", "Female"];
		  const typeProps = ["Origin", "Wild", "Hybrid"];
		  const rarityProps = ["Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical"];
			console.log(d.nbmonStats);
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
		  const genera = generaProps[parseInt(d.nbmonStats[5]) - 1];

		  const hidden = false;
		  
		  console.log(gender+rarity+type+genera);
	
		  const element = (<div key={dogId - 2} className="col-md-4">
		  <div className="card nbmon-card">
		  <img src={NBMonImages[parseInt(d.nbmonStats[5]) - 1]}></img>
		  Gender: {gender} <br/>
		  Rarity: {rarity} <br/>
		  Type: {type} <br/>
		  Genera: {genera} <br/>
		  </div>
		  </div>);
		  setNBMons(oldArray => [...oldArray, {nbcard: element, id: d.nbmonId, _gender: gender, _rarity: rarity, _type: type, _genera: genera, _hidden: hidden}]);
		  console.log(d);
		}
		
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

		const abi = NBMonCore.abi;
		const web3 = await Moralis.Web3.enableWeb3();
		const contract = new web3.eth.Contract(abi, TOKEN_CONTRACT_ADDRESS);

		const totalPrice = 220;

		const _finalAttack = attackPar;
		const _finalHealth = healthPar;
		const _finalStamina = staminaPar;
		const _finalURI = metaURL;
		const _finalPrice = web3.utils.toBN(totalPrice * 100000000000);

		console.log(_finalPrice);
		console.log("FINAL PRICE");

		const receipt = await contract.methods.mintExternal(_finalAttack,
			_finalHealth,
			_finalStamina,
			_finalURI,
			_finalPrice).send({from: web3.currentProvider.selectedAddress, value: _finalPrice});
		console.log(receipt);

		getBSCbalance();
		displayNBMons();

		
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
	useEffect(() => {
		console.log(NBMons);
	}, [NBMons])
  return (
		<div className="container">
		
		 <div className="row">
		 <div className="col-3">
		 	<div className="card">
	<article className="card-group-item">
		<header className="card-header">
			<h6 className="title">Element</h6>
		</header>
		<div className="filter-content">
			<div className="card-body">
			<Multiselect 
			options={elementOptions}
			displayValue="name"
			onSelect={arrangeNBMons}
			onRemove={arrangeNBMons}
			/>
			</div> 
		</div>
	</article>
	<article className="card-group-item">
		<header className="card-header">
			<h6 className="title">Genera</h6>
		</header>
		<div className="filter-content">
			<div className="card-body">
			<Multiselect 
			options={generaOptions}
			displayValue="name"
			onSelect={(selectedList, selectedItem) => {arrangeNBMons(selectedList, "Genera")}}
			onRemove={(selectedList, removedItem) => {arrangeNBMons(selectedList, "Genera")}}
			/>
			</div> 
		</div>
	</article> 
	<article className="card-group-item">
		<header className="card-header">
			<h6 className="title">Gender</h6>
		</header>
		<div className="filter-content">
			<div className="card-body">
			<Multiselect 
			options={genderOptions}
			onSelect={(selectedList, selectedItem) => {console.log(selectedList)}}
			displayValue="name"
			onSelect={(selectedList, selectedItem) => {arrangeNBMons(selectedList, "Gender")}}
			onRemove={(selectedList, removedItem) => {arrangeNBMons(selectedList, "Gender")}}
			/>
			</div> 
		</div>
	</article> 
	<article className="card-group-item">
		<header className="card-header">
			<h6 className="title">Type</h6>
		</header>
		<div className="filter-content">
			<div className="card-body">
			<Multiselect 
			options={typeOptions}
			displayValue="name"
			onSelect={(selectedList, selectedItem) => {arrangeNBMons(selectedList, "Type")}}
			onRemove={(selectedList, removedItem) => {arrangeNBMons(selectedList, "Type")}}
			/>
			</div> 
		</div>
	</article>
	<article className="card-group-item">
		<header className="card-header">
			<h6 className="title">Rarity</h6>
		</header>
		<div className="filter-content">
			<div className="card-body">
			<Multiselect 
			options={rarityOptions}
			displayValue="name"
			onSelect={(selectedList, selectedItem) => {arrangeNBMons(selectedList, "Rarity")}}
			onRemove={(selectedList, removedItem) => {arrangeNBMons(selectedList, "Rarity")}}
			/>
			</div> 
		</div>
	</article>   
</div>

		 </div>
		 <div className="col-9 gallery-block">
		 <div className="sort-block">
		 	<button>Sort</button>
		 	<button><i className="fas fa-th-large"></i></button>
		 	<button><i className="fas fa-list"></i></button>
		 </div>
		 <div className="row nb-gallery-showcase">
			{NBMons.map((item) => {if(item._hidden == false){return item.nbcard}})}
		 </div>
		 </div>
		 </div>

		</div>
	  );
}
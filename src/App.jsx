import React from "react";
import { useEffect, useState } from "react";
import NBMonMinting from "./contracts/NBMonMinting.json"
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Marketplace, Navigation, Gallery} from "./components";


import Birvo from "./BirvoTransparent.png"
import Dranexx from "./DranexxTransparent.png"
import Lamox from "./LamoxPTransparent.png"
import Licorine from "./LicorineTransparent.png"
import Milnas from "./MilnasTransparent.png"
import Pongu from "./PonguTransparent.png"
import Roggo from "./RoggoTransparent.png"
import Schoggi from "./SchoggiTransparent.png"
import Teree from "./TereeTransparent.png"
import Todillo from "./TodilloTransparent.png"
import Prawdek from "./PrawdekTransparent.png"




import "./App.css"
import RealmHunter from "./realmhunterlogo.png"
import { useMoralis } from "react-moralis"


const TOKEN_CONTRACT_ADDRESS = "0xd59916ee966152fab4f3fa23eb8187ee5a4fde18";


function App () {
	const { Moralis, isAuthenticated, authenticate, logout } = useMoralis();

	const [NBMonsRouted, setNBMons] = useState([]);

	const passivesFilter = ["Cold Shield", "Spirits Shield", "Tenacity Shield", "Hammer Shield", "Healing Essence", "Restoring Essence", 
"Last Health Essence", "Phantom Essence", "Energy Banner", "Revitalizing Banner", "Life Banner",
"Charging Banner", "Flaming Sword", "Soul-Shattering Sword", "Avenger Sword", "Jakugan Sword", "Amulet of Haste",
"Widow Amulet", "Supercharged Amulet", "Osur's Amulet", "Enraged Mask", "Mask of Darkness", "Fury Mask", "Baltasar's Mask"];

	const displayNBMons = async () => {
		setNBMons([]);
		const abi = NBMonMinting.abi;
		const web3 = await Moralis.Web3.enableWeb3();
		const contract = new web3.eth.Contract(abi, TOKEN_CONTRACT_ADDRESS);
		const dataArray = await contract.methods.getOwnerNBMonIds(web3.currentProvider.selectedAddress).call({from: web3.currentProvider.selectedAddress});
		
		const NBMonImages = [Lamox, Licorine, Birvo, Dranexx, Teree, Milnas, Schoggi, Pongu, Prawdek, Roggo, Todillo];
		console.log(dataArray);
		//for(const dogId of dataArray) {
		dataArray.forEach(async (dogId) => {
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
		  const genera = generaProps[parseInt(d.nbmonStats[4]) - 1];
		  const passives = [passivesFilter[parseInt(d.passives[0])], passivesFilter[parseInt(d.passives[1])]];

			const element = (
			<Route path={"/nbmons/"+dogId} element={
			<div className="row row-solo">
			<div className="col-md-4">
			<a href="/" className="back-marketplace-button">
			
			<i className="fas fa-arrow-left"> </i> Go back to the Marketplace</a></div>
			<div key={dogId} className="col-md-4">
			<div className="solo-nb">
							
			<a href={"/nbmons/" + dogId}><div className="card nbmon-card">
		  <img src={NBMonImages[parseInt(d.nbmonStats[4]) - 1]}></img>
		  Gender: {gender} <br/>
		  Rarity: {rarity} <br/>
		  Type: {type} <br/>
		  Genera: {genera} <br/>
			Passives: {passives[0]}, {passives[1]} <br/>
			Inherited Passives: None <br/>
			Inherited Moves: None <br/>
			Potential Stats: 
			<span className="fas fa-briefcase-medical"><i className="fapot">{d.potential[0]}</i></span> Health	
			<span className="fas fa-fire-alt"><i className="fapot">{d.potential[1]}</i></span> Energy
			<span className="fas fa-khanda"><i className="fapot">{d.potential[2]}</i></span> Attack
			<span className="fas fa-shield-alt"><i className="fapot">{d.potential[3]}</i></span> Defense
			<span className="fab fa-gripfire"><i className="fapot">{d.potential[4]}</i></span> Special Attack
			<span className="fab fa-hive"><i className="fapot">{d.potential[5]}</i></span> Special Defense
			<span className="fas fa-road"><i className="fapot">{d.potential[6]}</i></span> Speed

		  
		  </div></a></div>
			</div>
			</div>
		} />
			);
			setNBMons(oldArray => [...oldArray, element]);
			console.log(element);
		}); 

	};

	useEffect(() => {
	  if(isAuthenticated){
		displayNBMons();
	  }
	console.log("USEFE");
	}, [isAuthenticated]);
    return(
      <BrowserRouter>
      <div className="realmhunter-logo">
      	<a href="/"><img src={RealmHunter} /></a>
      </div>

        <Navigation />
        <Routes>
          <Route path="/" element={<Gallery />} />
          <Route path="/marketplace" element={<Marketplace />} />
		{NBMonsRouted}
          
          <Route path="/item/404" element={<div>gosdk</div>} />
          
        </Routes>
      </BrowserRouter>
      );
}


export default App;
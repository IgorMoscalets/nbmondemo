import React from "react";
import { useEffect, useState } from "react";
import Token from "./contracts/Token.json"
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Marketplace, Navigation, Gallery} from "./components";



import "./App.css"
import RealmHunter from "./realmhunterlogo.png"
import { useMoralis } from "react-moralis"


const TOKEN_CONTRACT_ADDRESS = "0x9A1158521a35032573BD96FBDeDbdd8867E74EF0";


function App () {
	const { Moralis, isAuthenticated, authenticate, logout } = useMoralis();

	const [NBMonsRouted, setNBMons] = useState([]);

	const displayNBMons = async () => {
		setNBMons([]);
		const abi = Token.abi;
		const web3 = await Moralis.Web3.enableWeb3();
		const contract = new web3.eth.Contract(abi, TOKEN_CONTRACT_ADDRESS);
		const dataArray = await contract.methods.getAllTokensForUser(web3.currentProvider.selectedAddress).call({from: web3.currentProvider.selectedAddress});
		
		console.log(dataArray);
		//for(const dogId of dataArray) {
		dataArray.forEach(async (dogId) => {
			const d = await contract.methods.getTokenDetails(dogId).call({from: web3.currentProvider.selectedAddress});
			const nftTokenURI = d.tokenURI;
			const response = await fetch(nftTokenURI);
			const jsonResponse = await response.json();
			console.log(jsonResponse);

			const nftImageURI = jsonResponse.image;
			console.log(dogId);

			const element = (
			<Route path={"/item/"+dogId} element={
			<div className="row row-solo">
			<div className="col-md-4">
			<a href="/" className="back-marketplace-button">
			
			<i className="fas fa-arrow-left"> </i> Go back to the Marketplace</a></div>
			<div key={dogId} className="col-md-4">
			<div className="solo-nb">
							
			<a className="nb-link" href={"/item/"+dogId.toString()}><div className="card nb-card">
			<img src={nftImageURI}></img>
			<div className="nbmonname">{jsonResponse.name}</div> <br/>
			<span className="nb-description">{jsonResponse.description}</span> <br/>
			<p className="card-icons"><i className="fas fa-heart"></i>{d.health} 
			<i className="fas fa-khanda"></i>{d.stamina}  
			<i className="fas fa-shield-alt"></i>{d.attack} </p> 
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
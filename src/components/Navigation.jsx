import React from "react";
import { Link } from "react-router-dom";


import { useEffect, useState } from "react";
import PriceGetter from "../contracts/PriceGetter.json";
import Token from "../contracts/Token.json"

import { useMoralis, useNativeBalance } from "react-moralis";


const PRICEGETTER_CONTRACT_ADDRESS = "0xf21F90585fD99281cefdfdb5A3307082FE62E2B7";


export const Navigation = () : React.ReactElement => {


	const { Moralis, isAuthenticated, authenticate, logout } = useMoralis();

	const[bscBalance, setBscBalance] = useState();
	const[bscToUsdBalance, setBscToUsdBalance] = useState();


	const getBSCbalance = async () => {
		const web3 = await Moralis.enableWeb3();
		const abi = PriceGetter.abi
		const contract = new web3.eth.Contract(abi, PRICEGETTER_CONTRACT_ADDRESS);
		const BscToUsdData = await contract.methods.getLatestPrice().call() / 100000000;
		console.log(BscToUsdData);

		const balance = await web3.eth.getBalance(web3.currentProvider.selectedAddress);
		const balanceDeci = web3.utils.fromWei(balance);
		console.log(balanceDeci);

		setBscBalance(balanceDeci.toString().substring(0, 5));
		setBscToUsdBalance((balanceDeci * BscToUsdData).toString().substring(0, 5));
	};

	useEffect(() => {
	  if(isAuthenticated){
		getBSCbalance();
	  }
	console.log("USEFE");
	}, [isAuthenticated]);
  return (
    <div className="navigation">
	     <ul className="nav nav-tabs">
		  <li className="nav-item navi-left">
		    <a className="nav-link" aria-current="page" href="/">Gallery</a>
		  </li>
		  <li className="nav-item navi-left">
		    <a className="nav-link" href="/marketplace">Marketplace</a>
		  </li>
		  
		  {!isAuthenticated ? 
		  	<li className="nav-item navi-right navi-login">
		<button className="nav-link" onClick={() => authenticate()}> Authenticate </button>
		</li>
		
		 : <li className="nav-item navi-right navi-login">
			 <button className="nav-link" onClick={() => logout()}>Log Out</button>
		 <span className="balance-show">{bscBalance} BNB ({bscToUsdBalance} USD)</span>
		 </li>}

		 <li className="nav-item navi-right">
		    <a className="nav-link" href="/contact">Contact Us</a>
		  </li>
		</ul>
    </div>
  );
}
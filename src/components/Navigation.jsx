import React from "react";
import { Link } from "react-router-dom";


import { useEffect, useState } from "react";
import PriceGetter from "../contracts/PriceGetter.json";
import Token from "../contracts/Token.json"

import { useMoralis, useNativeBalance } from "react-moralis";


const PRICEGETTER_CONTRACT_ADDRESS = "0xf21F90585fD99281cefdfdb5A3307082FE62E2B7";


export const Navigation = () : React.ReactElement => {


	const { Moralis, isAuthenticated, logout } = useMoralis();

	const[bscBalance, setBscBalance] = useState();
	const[bscToUsdBalance, setBscToUsdBalance] = useState();
	const[showLogin, setShowLogin] = useState(false);
	const[isLoggedIn, setIsLoggedIn] = useState(false);
	const[showPassword, setShowPassword] = useState(false);

	const[email, setEmail] = useState("");
	const[loginPassword, setLoginPassword] = useState("");
	const[signUpPassword, setSignUpPassword] = useState("");


	const[showCurEmail, setShowCurEmail] = useState("");
	const[showLoginAlready, setShowLoginAlready] = useState(false);

	const handleEmailChange = (event) => setEmail(event.target.value);
	const handleLoginPassword = (event) => setLoginPassword(event.target.value);
	const handleSignUpPassword = (event) => setSignUpPassword(event.target.value);


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

	const authenticateUser = async () => {
		await Moralis.authenticate();
		setShowLogin(true);
	};
	const loginAddEmail = async () => {
		Moralis.User.currentAsync().then(async function(user){
			setShowPassword(true);
			console.log(user.get("username"));
			if(user.get("username").includes("@")){
				if(user.get("username") == email){
					setShowLoginAlready(true);
				}
				else{
					alert("This wallet is already registered on our site. Please use the correct email.")
				}
			}
			else{
				setShowLoginAlready(false);
			}
		});
	};
	const loginWithPassword = async () => {
		try{
			const user = await Moralis.User.logIn(email, loginPassword);
			console.log("someshit"+email+loginPassword);
		} catch(error){
			alert("Invalid password");
			logout();
		} finally{
		setShowLogin(false);
		setIsLoggedIn(true);
		window.location.reload();
		}
	};
	const signUpWithPassword = async () => {
		Moralis.User.currentAsync().then(async function(user){
			user.setUsername(email);
			user.setPassword(signUpPassword);
			await user.save();
			setShowLogin(false);
			setIsLoggedIn(true);
			window.location.reload();
		});
	};
	const logUserOut = async () => {
		logout();
		setIsLoggedIn(false);
	};

	useEffect(() => {
	if(isAuthenticated || isLoggedIn){
	Moralis.User.currentAsync().then(function(user){
	  if(user.get("username").includes("@")){
	  	setIsLoggedIn(true);
		getBSCbalance();
		setShowCurEmail(user.get("username"));
		}
	  });
	}
	}, [isAuthenticated, isLoggedIn]);


  return (
    <div className="navigation">
	     <ul className="nav nav-tabs">
		  <li className="nav-item navi-left">
		    <a className="nav-link" aria-current="page" href="/">Gallery</a>
		  </li>
		  <li className="nav-item navi-left">
		    <a className="nav-link" href="/marketplace">Marketplace</a>
		  </li>
		  
		  {!(isAuthenticated && isLoggedIn) ? 
		  	<li className="nav-item navi-right navi-login">
		<button className="nav-link" onClick={authenticateUser}> Authenticate </button>
		</li>
		
		 : <div><li className="nav-item navi-right navi-login">
			 <button className="nav-link" onClick={logUserOut}>Log Out</button>
		
		 </li>
		 <span className="balance-show">{showCurEmail} : {bscBalance} BNB ({bscToUsdBalance} USD)</span></div>}

		 <li className="nav-item navi-right">
		    <a className="nav-link" href="/contact">Contact Us</a>
		  </li>
		</ul>

		{showLogin ? <div className="largelogin">
			<div className="login-block">
				<span className="login-title">Please provide us with your email</span>
				<input value={email} onChange={handleEmailChange} placeholder="email" />
				<button onClick={loginAddEmail}>Enter your email</button>
				{showPassword && <div> {showLoginAlready ? 
				<div className="login-showup">
					Log In with your password.
					<input value={loginPassword} onChange={handleLoginPassword} placeholder="password" />
					<button onClick={loginWithPassword}>Log In</button>
				</div>
					: 
				<div className="login-showup">
					Sign Up with new password.
					<input value={signUpPassword} onChange={handleSignUpPassword} placeholder="password" />
					<button onClick={signUpWithPassword}>Sign Up</button>
				</div>
				} </div>}
			</div>
		</div> : <div></div>}
    </div>
  );
}
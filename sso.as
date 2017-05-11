//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
import com.adobe.crypto.MD5;
import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.hash.IHash;
import com.hurlant.crypto.symmetric.ICipher;
import com.hurlant.crypto.symmetric.IPad;
import com.hurlant.crypto.symmetric.IVMode;
import com.hurlant.crypto.symmetric.PKCS5;
import com.hurlant.util.Base64;
import com.hurlant.util.Hex;

import flash.desktop.NativeApplication;
import flash.net.NetworkInfo;
import flash.net.NetworkInterface;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.net.navigateToURL;

import mx.controls.Alert;
import mx.core.INavigatorContent;
import mx.core.Application;
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
private var serverUrl:String="http://searcelabs.dev-happierhr.appspot.com";
private var environment:String="DEV";// can be DEV or PROD
private var Username:String;
private var Appname:String = "searceSSO";
private var Version:String = "0.6.2014.26";
private var Accesstoken:String;
private var Secretkey:String;
private var SessionID:String;
private var InitURL:String =serverUrl+ "/happierSSO/sso/initlogin";
private var AuthenticationURL:String =serverUrl+ "/happierSSO/sso/auth";
private var RegisterURL:String = serverUrl+ "/happierSSO/sso/register";
private static const IVString:String = "Q@FDdfdW54234fds";
private var URLLoaderObj:URLLoader;
private var PreviousAciveFrame:INavigatorContent;
private var ProgressBarMessage:String;
private var ErrorMessage:String;
private var ShowHideErrorMessagePanel:Boolean = false;
private var RegisterMessage:String
private var LogoUrl:String;
//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

import crypto_test.SymmetricCrypter;

private function getServerUrl() : String
{
	if(this.environment=="DEV")
		this.serverUrl="http://searcelabs.dev-happierhr.appspot.com";
	else
		this.serverUrl="http://searcelabs.happierhr.appspot.com";
	return this.serverUrl
}

private static function encrypt(param1:String, param2:String) : String
{
	while(param1.length%16 !=0)
	{
		param1= param1+"$";
	}
	var crypter= SymmetricCrypter.createAESCrypter(param2);
	var start:int=0;
	var end:int=15;
	var encryptedtext:String="";
	
	while(end <= param1.length-1)
	{
		var str:String;
		str=param1.substr(start,16);
		str=crypter.encrypt(str);
		start+=16;
		end+=16;
		encryptedtext=encryptedtext+str;
	}
	return encryptedtext;
}	

private static function md5Hash(param1:String) : String
{
	var hash:String = MD5.hash(param1);
	return hash;
}

private function Init() : void
{
	
	var _loc1_:Object = new Object();
	_loc1_.type = "INIT";
	_loc1_.appname = this.Appname;
	_loc1_.version = this.Version;
	ProgressBarObject.label = "Connecting to server...";
	BtnOk.includeInLayout=false;
	BtnOk.visible=false;
	this.Sendmessage(this.InitURL,_loc1_);
}

private function Login() : void
{
	var _loc2_:Object = new Object();
	_loc2_.type = "LOGIN";
	_loc2_.loginid ='yash.choubey@searcelabs.com';//this.txtUser.text;
	_loc2_.password ='Searce@Hero2017';//this.txtPassword.text;
	_loc2_.macadds = this.GetMacIDs();
	ProgressBarObject.label = "Processing.....";
	this.Sendmessage(this.AuthenticationURL,_loc2_);
}

private function Register(param1:String, param2:String) : void
{
	var _loc3_:Object = new Object();
	_loc3_.type = param1;
	_loc3_.username = this.Username;
	_loc3_.messagetoapprove = this.txtRegisterReason.text;
	switch(param1)
	{
		case "REGISTER":
			_loc3_.macadds = this.GetMacIDs();
			break;
		case "SKIP":
	}
	ProgressBarObject.label = param2;
	this.Sendmessage(this.RegisterURL,_loc3_);
}

private function Sendmessage(param1:String, param2:Object) : void
{
	var _loc3_:URLRequest = new URLRequest(param1);
	var _loc4_:URLVariables = new URLVariables();
	if(param2.type == "LOGIN")
	{
		_loc4_.digest = md5Hash(param2.loginid + param2.password + param2.macadds);
	}
	if(this.Accesstoken != null)
	{
		_loc4_.token = this.Accesstoken;
	}
	if(this.SessionID != null)
	{
		param2.sessionid = this.SessionID;
	}
	var _loc5_:String = JSON.stringify(param2);
	if(param2.type == "LOGIN")
	{
		_loc4_.message = encrypt(_loc5_,this.Secretkey);
	}
	else
	{
		_loc4_.message = _loc5_;
	}
	_loc3_.data = _loc4_;
	_loc3_.method = URLRequestMethod.POST;
	this.URLLoaderObj = new URLLoader(_loc3_);
	
	this.URLLoaderObj.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,this.httpStatusHandler);
	this.URLLoaderObj.addEventListener(IOErrorEvent.IO_ERROR,this.httpErrorHandler);
	this.URLLoaderObj.addEventListener(Event.COMPLETE,this.httpStatusComplete);
	
}

private function httpStatusComplete(param1:Event) : void
{
	
	var _loc2_:Object = null;
	if(this.URLLoaderObj.data != null && this.URLLoaderObj.data != "")
	{
		BtnOk.visible = true;
		if(this.URLLoaderObj.data != null && this.URLLoaderObj.data != "")
		{
			_loc2_ = JSON.parse(this.URLLoaderObj.data);
			switch(_loc2_.success.toString().toUpperCase())
			{
				case "TRUE":
					trace("_loc2_.type.toString().toUpperCase() "+_loc2_.type.toString().toUpperCase());
					switch(_loc2_.type.toString().toUpperCase())
					{
						case "INIT":
							this.Accesstoken = _loc2_.accesstoken;
							this.Secretkey = String(_loc2_.key);
							if(this.LogoUrl == null)
							{
								
								this.LogoUrl = _loc2_.defaultlogourl;
							}
							this.Writepreferences();
							this.SetActiveFrame(this.LoginFrame);
							break;
						case "LOGIN":
							this.SessionID = _loc2_.sessionid;
							this.Username=_loc2_.username;
							if(this.LogoUrl !== _loc2_.defaultlogourl)
							{
								this.LogoUrl = _loc2_.defaultlogourl;
							}
							this.Writepreferences();
							break;
						case "REGISTER":
						case "SKIP":
					}
					if(_loc2_.action != null)
					{	
						trace("_loc2_.action.toString().toUpperCase() "+_loc2_.action.toString().toUpperCase());
						switch(_loc2_.action.toString().toUpperCase())
						{
							case "REDIRECT":
								if(_loc2_.url != null)
								{
									navigateToURL(new URLRequest(_loc2_.url));
									AutoCloseWindow();
								}
								break;
							case "REGISTERANDSKIP":
								this.SetActiveFrame(this.RegisterFrame);
								break;
							case "REGISTER":
								this.SetActiveFrame(this.RegisterFrame);
								BtnSkip.includeInLayout = false;
								BtnSkip.visible = false;
								break;
							case "SKIP":
								this.SetActiveFrame(this.RegisterFrame);
								BtnRegister.visible = false;
								this.RegisterMessage = _loc2_.message;
								break;
							case "DONE":
								this.SetActiveFrame(this.ProgressBarFrame)
								this.DisplayMessage("",_loc2_.message,true);
								BtnOk.visible = false;
								BtnOk.includeInLayout = false;
								break;
						}
					}
					break;
				case "FALSE":
					this.SetActiveFrame(this.ProgressBarFrame)
					if(_loc2_.action != null && _loc2_.action.toString().toUpperCase() == "DONE")
					{
						this.DisplayMessage("",_loc2_.message,true);
					}
					else
					{
						this.DisplayMessage("Error",_loc2_.message,false);
					}
			}
		}
	}
}

private function httpErrorHandler(param1:IOErrorEvent) : void
{
	this.DisplayMessage("Error","Status: " + param1.errorID,true);
}

private function httpStatusHandler(param1:HTTPStatusEvent) : void
{
	if(param1.status != 200)
	{
		this.DisplayMessage("Error","Status: " + param1.status,false);
	}
}

private function SetActiveFrame(param1:INavigatorContent) : void
{
	this.PreviousAciveFrame = this.FramContainer.selectedChild;
	this.FramContainer.selectedChild = param1;
}

private function RollBackActiveFrame() : void
{
	this.ShowHideErrorMessagePanel = false;
	if(this.PreviousAciveFrame != null)
	{
		this.FramContainer.selectedChild = this.PreviousAciveFrame;
	}
}


public function GetMacIDs() : String
{
	var _loc1_:String = null;
	var _loc4_:NetworkInterface = null;
	var _loc5_:NetworkInterface = null;
	var _loc2_:NetworkInfo = NetworkInfo.networkInfo;
	var _loc3_:Vector.<NetworkInterface> = _loc2_.findInterfaces();
	for each(_loc4_ in _loc3_)
	{
		_loc5_ = _loc4_ as NetworkInterface;
		if(_loc5_.hardwareAddress != "")
		{
			if(_loc1_ == null)
			{
				_loc1_ = _loc5_.hardwareAddress;
			}
			else
			{
				_loc1_ = _loc1_ + ("$" + _loc5_.hardwareAddress);
			}
		}
	}
	return _loc1_;
}

private function DisplayMessage(param1:String, param2:String, param3:Boolean) : void
{
	ProgressBarObject.label=param1;
	ProgressBarObject.visible=false;
	ProgressBarObject.includeInLayout=false;
	_gControl_Text1.text=param1+" "+param2;
	_gControl_Text1.visible= true;
	if(param3)
	{
		this.BtnOk.removeEventListener(MouseEvent.CLICK,RollBackActiveFrame);
		this.BtnOk.addEventListener(MouseEvent.CLICK,CloseApp);
		BtnOk.visible = false;
	}
}


public function BtnOk_click() : void
{
	this.RollBackActiveFrame();
}

public function CloseApp() : void
{
	NativeApplication.nativeApplication.exit();	
}
public function continueRegister() : void
{
	this.Register("REGISTERANDPROCEED","Processing ....");
}
public function skipRegister() : void
{
	this.Register("SKIP","Processing ....");
}
public function onlyRegister() : void
{
	this.Register("REGISTER","Processing ....");
}
private function AutoCloseWindow() : void
{
	var _loc1_:Timer = new Timer(2000,1);
	_loc1_.addEventListener(TimerEvent.TIMER_COMPLETE,this.WaitTimerHandler);
	_loc1_.start();
}
public function WaitTimerHandler(param1:TimerEvent) : void
{
	this.CloseApp();
}
private function Writepreferences() : void
{
	var _loc1_:XML = new XML("<Preferences><Domainlogourl>" + this.LogoUrl + "</Domainlogourl><Version>" + this.Version + "</Version></Preferences>");
	var _loc2_:File = File.applicationStorageDirectory.resolvePath("preferences.dat");
	var _loc3_:FileStream = new FileStream();
	_loc3_.open(_loc2_,FileMode.WRITE);
	_loc3_.writeUTFBytes(Base64.encode(_loc1_));
	_loc3_.close();
}

public function Readpreferences() : void
{
	var _loc2_:FileStream = null;
	var _loc3_:String = null;
	var _loc4_:XML = null;
	var _loc1_:File = File.applicationStorageDirectory.resolvePath("preferences.dat");
	if(_loc1_.exists)
	{
		_loc2_ = new FileStream();
		_loc2_.open(_loc1_,FileMode.READ);
		_loc3_ = _loc2_.readUTFBytes(_loc2_.bytesAvailable);
		_loc4_ = XML(Base64.decode(_loc3_));
		if(this.Version.toString() != _loc4_.Version[0].toString())
		{
			_loc2_.close();
			_loc1_.deleteFile();
			return;
		}
		this.LogoUrl = _loc4_.Domainlogourl[0];
		loader1.source=LogoUrl;
		_loc2_.close();
	}
	
	Init();
	
}

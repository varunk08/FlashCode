<?php
class PenFight   //main class creates tables, handles users.
{
	const MAX_PLAYERS = 4;
	public $playersArray;
	
	public function __construct()
	{
		mysql_connect("localhost","dragoni6_Wiz","W1zXon3");
        mysql_select_db("dragoni6_penfightdb");
    	$playersArray = array();
	}
    
    public function getGameList()
    {
		$result=mysql_query("SELECT * FROM dragoni6_penfightdb.groupstable WHERE groupstable.numPlayers < 4");
        $t = array();
        
        while($row=mysql_fetch_assoc($result))
        {
            array_push($t,$row);
        }
        
        return $t;
    }
	
	
	public  function newGroup($grpCreate)
	{
		$time=time();
		$this->doGroupsMaintenance();
		$new_result = mysql_query("INSERT INTO dragoni6_penfightdb.groupstable (groupName,numPlayers,gameStarted,renewal) VALUES ('$grpCreate->groupName','1',false,'$time')");
		if($new_result)
		{
			mysql_query("UPDATE dragoni6_penfightdb.playerstable SET groupName =  '$grpCreate->groupName' WHERE playerstable.playerName = '$grpCreate->name'");
			return "Group Created at DB";
		}
		else return "Group Creation Error";
	}
	
	public function registerPlayer($player)
	{	
		$timeNow = time();
		
		$result = mysql_query("INSERT INTO dragoni6_penfightdb.playerstable (playerName,peerID,groupName,renewal) VALUES ('$player->name','$player->peerID',NULL,'$timeNow')");
		$this->doPlayersMaintenance();
		if($result)
		{
			return "Player registered";
		}
		else return "Registration Error";
	}

	public function renewRegistration($renewPlayer)
	{
		$time = time();
		$plrName = $renewPlayer->name;
		
		$this->doPlayersMaintenance();
		$this->renewGroup($plrName,$time);
		$result = mysql_query("UPDATE dragoni6_penfightdb.playerstable SET playerstable.renewal='$time' WHERE playerstable.playerName='$plrName'");
		
		
		if($result)
		{
			//mysql_free_result($result);
			return "Renewed";
		}
		else return "RenewalError";
	}
	
	public function joinGame()
	{
		$this->doGroupsMaintenance();
		$result = mysql_query("SELECT * FROM dragoni6_penfightdb.groupstable WHERE numPlayers<4 AND gameStarted=false");
		if($result)
		{	
			$t = array();
	        
	        while($row=mysql_fetch_assoc($result))
	        {
	            array_push($t,$row);
	        }
	        
	        return $t;
		}
		
		else return "NO_GAMES_ONLINE";
	}
	
	public function gameSelect($gameSelectObj)
	{
		$result = mysql_query("UPDATE dragoni6_penfightdb.playerstable SET groupName='$gameSelectObj->group' WHERE playerstable.playerName='$gameSelectObj->name'");
		
		
		if($result)
		{
			mysql_query("UPDATE dragoni6_penfightdb.groupstable SET numPlayers=numPlayers+1 WHERE groupstable.groupName='$gameSelectObj->group'");
			return "Game Selected";
		}
		else return "Game selection error";
	}
	
	public function gameStarted($gameName)
	{
		$now=time();
		mysql_query("UPDATE dragoni6_penfightdb.groupstable SET gameStarted=true,renewal='$now' WHERE groupstable.groupName='$gameName'");
		
		
	}
	
	public function findUserName($peerID)
	{
		//$result = mysql_query("SELECT playerName FROM dragoni6_penfightdb.playerstable WHERE peerID='$peerID'");
		$result = mysql_query("SELECT * FROM dragoni6_penfightdb.playerstable WHERE peerID='$peerID'");
		$row = mysql_fetch_object($result);
		return  $row;
	}
	
	public function quitMyGame($playerName)
	{
		$result = mysql_query("SELECT playerstable.groupName FROM dragoni6_penfightdb.playerstable WHERE playerstable.playerName = '$playerName' ");
		$row = mysql_fetch_assoc($result);
		$groupName = $row["groupName"];
		mysql_query("UPDATE dragoni6_penfightdb.playerstable SET groupName=NULL WHERE playerstable.playerName='$playerName'");
		
		mysql_query("UPDATE dragoni6_penfightdb.groupstable SET numPlayers=numPlayers-1 WHERE groupstable.groupName='$groupName'");
		$result = mysql_query("SELECT numPlayers FROM dragoni6_penfightdb.groupstable WHERE groupstable.groupName = '$groupName'");
		$row = mysql_fetch_assoc($result);
		$numPlaying = $row["numPlayers"];
		if($numPlaying == 0)
		{
			mysql_query("DELETE FROM dragoni6_penfightdb.groupstable WHERE groupstable.groupName='$groupName'");
		}
		mysql_query("DELETE FROM dragoni6_penfightdb.playerstable WHERE playerstable.playerName ='$playerName'");
	}



	
	private function doPlayersMaintenance()
	{
		$result=mysql_query("SELECT playerName,renewal FROM dragoni6_penfightdb.playerstable");
		$now = time();
		while($row=mysql_fetch_assoc($result))
		{
			//print_r($row['playerName']." ".$row['renewal']."\n");
			$name = $row['playerName'];
			if($now - $row['renewal'] > 45)
			{
				mysql_query("DELETE FROM dragoni6_penfightdb.playerstable WHERE playerstable.playerName='$name'");
			}
		}
		
		
		//mysql_free_result($result);
	}
	
	private function doGroupsMaintenance()
	{
		$g_result=mysql_query("SELECT groupName,renewal FROM dragoni6_penfightdb.groupstable");
		$g_now = time();
		while($g_row=mysql_fetch_assoc($g_result))
		{
			//print_r($row['playerName']." ".$row['renewal']."\n");
			$name = $g_row['groupName'];
			if($g_now - $g_row['renewal'] > 45)
			{
				mysql_query("DELETE FROM dragoni6_penfightdb.groupstable WHERE groupstable.groupName='$name'");
			}
		}
		
		
		mysql_free_result($g_result);
	}
	
	private function renewGroup($plrName,$time)
	{
		$result1 = mysql_query("SELECT playerstable.groupName FROM dragoni6_penfightdb.playerstable WHERE playerstable.playerName = '$plrName'");
		$row1 = mysql_fetch_assoc($result1);
		$groupName = $row1["groupName"];
		$result = mysql_query("UPDATE dragoni6_penfightdb.groupstable SET groupstable.renewal='$time' WHERE groupstable.groupName='$groupName'");
	
		mysql_free_result($result1);
	}

}
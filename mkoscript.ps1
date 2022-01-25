cls
$Euro = [char]0x20AC
$array_konsoles="NSW","WUU","WII","NGC","N64","SNES","NES","3DS","NDS","GBA","GBC","GB","AMI","SDC","SAT","MD","32X","MS","GG","MCD","PS1","PS2","PS3","PS4","PS5","PSP","PSV","XBOX","X360","XONE","XSX"
$data = get-content .\games.txt
$Euro = [char]0x20AC
[single]$wechselkurs = 0.8587
foreach ($game in $data)
{
	$information = $game -split ';'
	write-host ""
	[single]$final_price = 0.0
	write-host "("$information[1]")"$information[0]"-"$information[2]
	$stringname = $information[0] -replace ' ','-'
	$stringname = $stringname -replace "---" ,"-"
	$stringname = $stringname -replace "'" ,"%27"
	if ($information[1] -eq "Nsw"){$pc_konsole_name="pal-nintendo-switch"}
	elseif ($information[1] -eq "Wuu"){$pc_konsole_name="pal-wii-u"}
	elseif ($information[1] -eq "Wii"){$pc_konsole_name="pal-wii"}
	elseif ($information[1] -eq "NGC"){$pc_konsole_name="pal-gamecube"}
	elseif ($information[1] -eq "N64"){$pc_konsole_name="pal-nintendo-64"}
	elseif ($information[1] -eq "SNES"){$pc_konsole_name="pal-super-nintendo"}
	elseif ($information[1] -eq "NES"){$pc_konsole_name="pal-nes"}
	elseif ($information[1] -eq "3DS"){$pc_konsole_name="pal-nintendo-3ds"}
	elseif ($information[1] -eq "NDS"){$pc_konsole_name="pal-nintendo-ds"}
	elseif ($information[1] -eq "GBA"){$pc_konsole_name="pal-gameboy-advance"}
	elseif ($information[1] -eq "GBC"){$pc_konsole_name="pal-gameboy-color"}
	elseif ($information[1] -eq "GB"){$pc_konsole_name="pal-gameboy"}
	elseif ($information[1] -eq "AMI"){$pc_konsole_name="amiibo"}
	elseif ($information[1] -eq "SDC"){$pc_konsole_name="pal-sega-dreamcast"}
	elseif ($information[1] -eq "SAT"){$pc_konsole_name="pal-sega-saturn"}
	elseif ($information[1] -eq "MD"){$pc_konsole_name="pal-sega-mega-drive"}
	elseif ($information[1] -eq "32X"){$pc_konsole_name="pal-mega-drive-32x"}
	elseif ($information[1] -eq "MS"){$pc_konsole_name="pal-sega-master-system"}
	elseif ($information[1] -eq "GG"){$pc_konsole_name="pal-sega-game-gear"}
	elseif ($information[1] -eq "MCD"){$pc_konsole_name="pal-sega-mega-cd"}
	elseif ($information[1] -eq "PS1"){$pc_konsole_name="pal-playstation"}
	elseif ($information[1] -eq "PS2"){$pc_konsole_name="pal-playstation-2"}
	elseif ($information[1] -eq "PS3"){$pc_konsole_name="pal-playstation-3"}
	elseif ($information[1] -eq "PS4"){$pc_konsole_name="pal-playstation-4"}
	elseif ($information[1] -eq "PSP"){$pc_konsole_name="pal-psp"}
	elseif ($information[1] -eq "PSV"){$pc_konsole_name="pal-playstation-vita"}
	elseif ($information[1] -eq "XBOX"){$pc_konsole_name="pal-xbox"}
	elseif ($information[1] -eq "X360"){$pc_konsole_name="pal-xbox-360"}
	elseif ($information[1] -eq "XONE"){$pc_konsole_name="pal-xbox-one"}	
	elseif ($information[1] -eq "XSX"){$pc_konsole_name="pal-xbox-series-x"}
	$url = "https://www.pricecharting.com/game/"+$pc_konsole_name+"/"+$stringname
	write-host $url
	$http_content = Invoke-WebRequest $url -Usebasicparsing
	if ($http_content.content -match " Game List")
	{
	write-host "	Game not found" -foregroundcolor red
	$information[0] = $information[0] -replace "'" ,"''"
	$update_query = "update prod_videogames set wertung=0 where name like '"+$information[0]+"' and konsole like '"+$information[1]+"'"
	$updaterequest = Invoke-MySqlQuery -Query $update_query
	}
	else 
	{
	write-host "	Game found" -foregroundcolor green
	$content_array = $http_content.content -split '<td id="used_price">'
	$used_price_temp = $content_array[1] -split "</span>"
	$used_price = $used_price_temp[0] -split "\n"
	$used_price[2]  = $used_price[2] -replace " ",""
	$used_price[2]  = $used_price[2] -replace "\$",""
	$content_array = $http_content.content -split '<td id="complete_price">'
	$complete_price_temp = $content_array[1] -split "</span>"
	$complete_price = $complete_price_temp[0] -split "\n"
	$complete_price[2]  = $complete_price[2] -replace " ",""
	$complete_price[2]  = $complete_price[2] -replace "\$",""
	$content_array = $http_content.content -split '<td id="new_price">'
	$new_price_temp = $content_array[1] -split "</span>"
	$new_price = $new_price_temp[0] -split "\n"
	$new_price[2]  = $new_price[2] -replace " ",""
	$new_price[2]  = $new_price[2] -replace "\$",""
	$content_array = $http_content.content -split '<td id="manual_only_price" class="tablet-portrait-hidden">'
	$manual_price_temp = $content_array[1] -split "</span>"
	$manual_price = $manual_price_temp[0] -split "\n"
	$manual_price[2]  = $manual_price[2] -replace " ",""
	$manual_price[2]  = $manual_price[2] -replace "\$",""
	if ($information[2] -eq "OVP")
	{
		if ($complete_price[2] -match 'N/A')
		{
			write-host "	Complete Price not found" -foregroundcolor magenta
			$information[0] = $information[0] -replace "'","''"
			$updaterequest = Invoke-MySqlQuery -Query $update_query
		}
		else
		{
			$complete_price[2] = [single]$complete_price[2]
			$final_price = $complete_price[2]
			write-host "	Complete Price is"$final_price -foregroundcolor cyan
		}
	}
	else
	{
		if ($used_price[2] -match 'N/A')
		{
			write-host "	Loose Price not found" -foregroundcolor magenta
			$information[0] = $information[0] -replace "'","''"
		}
		else
		{
			$used_price[2] = [single]$used_price[2]
			$final_price = $used_price[2]
			write-host "	Loose Price is"$final_price -foregroundcolor cyan
		}
	}
	if ($final_price -gt 0)
	{
		$total_price = $total_price + $final_price
	}
}
}
[int]$total_price = $total_price
write-host "		Total Value of Collection is currently" $total_price "$" -foregroundcolor cyan
[int]$total_price = $total_price*$wechselkurs
write-host "		Total Value of Collection is currently" $total_price "$Euro" -foregroundcolor cyan
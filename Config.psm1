##########
# Win 10 / Server 2016 / Server 2019 Initial Setup Script - Tweak library
# Author: Disassembler <disassembler@dasm.cz> - Version: v3.10, 2020-07-15
# Source: https://github.com/Disassembler0/Win10-Initial-Setup-Script
# With tweaks from https://github.com/khlam/Win10-Config/
# Tweaked by Cl3m3nt1n4
##########


##########
#region Chocolatey
##########

## Install Chocolatey if not already installed
Function InstallChoco {
	Write-Host "Installing chocolatey..."
	$error.clear()
	try { choco feature enable --name=useRememberedArgumentsForUpgrades }
	catch { 
		Write-Host -nonewline "Install chocolatey? (Y/N) "
		$response = read-host
		if ( $response -ne "Y" ) { return; }
		Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}
	if (!$error) {
		Write-Host "Chocolatey already installed."
	}
}

## Install all packages in chocoInstall.txt
Function InstallChocoPkgs {
	$file = "$psscriptroot\chocoInstall.txt"
	Write-Host "Installing all packages in $file that are not already installed..."
	if (Test-Path $file) {
        $toInstall = @()
        $params = @()
        foreach($line in Get-Content $file){
            $line = $line.split('|')
            $toInstall += $line[0]
            if (!($line[1] -eq "")) {
                $params += $line[1]
            }else {
                $params += ""
            }
        }
		if (!($toInstall.count -eq 0)) {
            $installed = [string[]](choco list --local-only | ForEach {"$_".Split(" ")[0]})
			$notInstalled = $toInstall | Where {$installed -NotContains $_}
			
			if (!($notInstalled.count -eq 0)){
				Write-Host "Found packages in $file that are not installed: $notInstalled"
				Write-Host -NoNewline "Install? (Y/N)"
				$response = read-host
				if ( $response -ne "Y" ) { return; }
				ForEach ($j in $notInstalled) {
                    $i = $toInstall.IndexOf($j)
                    $p = $params[$i]
                    Write-Host choco install $j $p -y 
					Invoke-Expression "choco install $j $p -y"
				}
			}else {
				Write-Host "All packages from $file installed."
			}
		}
	}else {
		Write-Host "Cannot find chocoInstall.txt."
	}
}

##########
#endregion Chocolatey
##########

##########
#region Host File
##########

Function HostFile {
Write-Output "Adding telemetry domains to hosts file"
$hosts_file = "$env:systemroot\System32\drivers\etc\hosts"
$domains = @(
    "184-86-53-99.deploy.static.akamaitechnologies.com"
    "a-0001.a-msedge.net"
    "a-0002.a-msedge.net"
    "a-0003.a-msedge.net"
    "a-0004.a-msedge.net"
    "a-0005.a-msedge.net"
    "a-0006.a-msedge.net"
    "a-0007.a-msedge.net"
    "a-0008.a-msedge.net"
    "a-0009.a-msedge.net"
    "a1621.g.akamai.net"
    "a1856.g2.akamai.net"
    "a1961.g.akamai.net"
    "a978.i6g1.akamai.net"
    "a.ads1.msn.com"
    "a.ads2.msads.net"
    "a.ads2.msn.com"
    "ac3.msn.com"
    "ad.doubleclick.net"
    "adnexus.net"
    "adnxs.com"
    "ads1.msads.net"
    "ads1.msn.com"
    "ads.msn.com"
    "aidps.atdmt.com"
    "aka-cdn-ns.adtech.de"
    "a-msedge.net"
    "any.edge.bing.com"
    "a.rad.msn.com"
    "az361816.vo.msecnd.net"
    "az512334.vo.msecnd.net"
    "b.ads1.msn.com"
    "b.ads2.msads.net"
    "bingads.microsoft.com"
    "b.rad.msn.com"
    "bs.serving-sys.com"
    "c.atdmt.com"
    "cdn.atdmt.com"
    "cds26.ams9.msecn.net"
    "choice.microsoft.com"
    "choice.microsoft.com.nsatc.net"
    "compatexchange.cloudapp.net"
    "corpext.msitadfs.glbdns2.microsoft.com"
    "corp.sts.microsoft.com"
    "cs1.wpc.v0cdn.net"
    "db3aqu.atdmt.com"
    "df.telemetry.microsoft.com"
    "diagnostics.support.microsoft.com"
    "e2835.dspb.akamaiedge.net"
    "e7341.g.akamaiedge.net"
    "e7502.ce.akamaiedge.net"
    "e8218.ce.akamaiedge.net"
    "ec.atdmt.com"
    "fe2.update.microsoft.com.akadns.net"
    "feedback.microsoft-hohm.com"
    "feedback.search.microsoft.com"
    "feedback.windows.com"
    "flex.msn.com"
    "g.msn.com"
    "h1.msn.com"
    "h2.msn.com"
    "hostedocsp.globalsign.com"
    "i1.services.social.microsoft.com"
    "i1.services.social.microsoft.com.nsatc.net"
    "ipv6.msftncsi.com"
    "ipv6.msftncsi.com.edgesuite.net"
    "lb1.www.ms.akadns.net"
    "live.rads.msn.com"
    "m.adnxs.com"
    "msedge.net"
    "msftncsi.com"
    "msnbot-65-55-108-23.search.msn.com"
    "msntest.serving-sys.com"
	"ntp.msn.com"                              #Blocks Edge Chromium New Tab reverting to Offline version
    "oca.telemetry.microsoft.com"
    "oca.telemetry.microsoft.com.nsatc.net"
    "onesettings-db5.metron.live.nsatc.net"
    "pre.footprintpredict.com"
    "preview.msn.com"
    "rad.live.com"
    "rad.msn.com"
    "redir.metaservices.microsoft.com"
    "reports.wes.df.telemetry.microsoft.com"
    "schemas.microsoft.akadns.net"
    "secure.adnxs.com"
    "secure.flashtalking.com"
    "services.wes.df.telemetry.microsoft.com"
    "settings-sandbox.data.microsoft.com"
    "sls.update.microsoft.com.akadns.net"
    "sqm.df.telemetry.microsoft.com"
    "sqm.telemetry.microsoft.com"
    "sqm.telemetry.microsoft.com.nsatc.net"
    "ssw.live.com"
    "static.2mdn.net"
    "statsfe1.ws.microsoft.com"
    "statsfe2.update.microsoft.com.akadns.net"
    "statsfe2.ws.microsoft.com"
    "survey.watson.microsoft.com"
    "telecommand.telemetry.microsoft.com"
    "telecommand.telemetry.microsoft.com.nsatc.net"
    "telemetry.appex.bing.net"
    "telemetry.microsoft.com"
    "telemetry.urs.microsoft.com"
    "vortex-bn2.metron.live.com.nsatc.net"
    "vortex-cy2.metron.live.com.nsatc.net"
    "vortex.data.microsoft.com"
    "vortex-sandbox.data.microsoft.com"
    "vortex-win.data.microsoft.com"
    "cy2.vortex.data.microsoft.com.akadns.net"
    "watson.live.com"
    "watson.microsoft.com"
    "watson.ppe.telemetry.microsoft.com"
    "watson.telemetry.microsoft.com"
    "watson.telemetry.microsoft.com.nsatc.net"
    "wes.df.telemetry.microsoft.com"
    "win10.ipv6.microsoft.com"
    "www.bingads.microsoft.com"
    "www.go.microsoft.akadns.net"
    "www.msftncsi.com"
    "client.wns.windows.com"
    "wdcp.microsoft.com"                       # may cause issues with Windows Defender Cloud-based protection
    #"dns.msftncsi.com"                         # This causes Windows to think it doesn't have internet
    #"storeedgefd.dsx.mp.microsoft.com"         # breaks Windows Store
    "wdcpalt.microsoft.com"
    "settings-ssl.xboxlive.com"
    "settings-ssl.xboxlive.com-c.edgekey.net"
    "settings-ssl.xboxlive.com-c.edgekey.net.globalredir.akadns.net"
    "e87.dspb.akamaidege.net"
    "insiderservice.microsoft.com"
    "insiderservice.trafficmanager.net"
    "e3843.g.akamaiedge.net"
    "flightingserviceweurope.cloudapp.net"
    "www-google-analytics.l.google.com"
    "hubspot.net.edge.net"
    "e9483.a.akamaiedge.net"

    "www.google-analytics.com"
    "padgead2.googlesyndication.com"
    "mirror1.malwaredomains.com"
    "mirror.cedia.org.ec"
    "stats.g.doubleclick.net"
    "stats.l.doubleclick.net"
    "adservice.google.de"
    "adservice.google.com"
    "googleads.g.doubleclick.net"
    "pagead46.l.doubleclick.net"
    "hubspot.net.edgekey.net"
    "insiderppe.cloudapp.net"                   # Feedback-Hub
    "livetileedge.dsx.mp.microsoft.com"

    # extra
    "fe2.update.microsoft.com.akadns.net"
    "s0.2mdn.net"
    "statsfe2.update.microsoft.com.akadns.net"
    "survey.watson.microsoft.com"
    "view.atdmt.com"
    "watson.microsoft.com"
    "watson.ppe.telemetry.microsoft.com"
    "watson.telemetry.microsoft.com"
    "watson.telemetry.microsoft.com.nsatc.net"
    "wes.df.telemetry.microsoft.com"
    "m.hotmail.com"

)
Write-Output "" | Out-File -Encoding ASCII -Append $hosts_file
foreach ($domain in $domains) {
    if (-Not (Select-String -Path $hosts_file -Pattern $domain)) {
        Write-Output "0.0.0.0 $domain" | Out-File -Encoding ASCII -Append $hosts_file
    }
}

Write-Output "Adding telemetry ips to firewall"
$ips = @(
    "134.170.30.202"
    "137.116.81.24"
    "157.56.106.189"
    "184.86.53.99"
    "2.22.61.43"
    "2.22.61.66"
    "204.79.197.200"
    "23.218.212.69"
    "65.39.117.230"
    "65.52.108.33"   # Causes problems with Microsoft Store
    "65.55.108.23"
    "64.4.54.254"
)
Remove-NetFirewallRule -DisplayName "Block Telemetry IPs" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Block Telemetry IPs" -Direction Outbound `
    -Action Block -RemoteAddress ([string[]]$ips)

}

##########
#endregion Host File
##########



##########
#region Auxiliary Functions
##########

# Wait for key press
Function WaitForKey {
	Write-Output "`nPress any key to continue..."
	[Console]::ReadKey($true) | Out-Null
}

# Restart computer
Function Restart {
	Write-Output "Restarting..."
	Restart-Computer
}

##########
#endregion Auxiliary Functions
##########





# Export functions
Export-ModuleMember -Function *

# network-info.ps1
# Išveda pagrindinius tinklo parametrus

Clear-Host
$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "Tinklo informacija - $time" -ForegroundColor Cyan
Write-Host "========================================`n"

# Adapteriai ir jų būklė
Write-Host "1) Tinklo adapteriai" -ForegroundColor Yellow
Get-NetAdapter -ErrorAction SilentlyContinue |
  Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress |
  Format-Table -AutoSize
Write-Host "`n"

# IP konfigūracija (IP adresai, tinklo kaukė, gateway, DNS)
Write-Host "2) IP konfigūracija" -ForegroundColor Yellow
Get-NetIPConfiguration -ErrorAction SilentlyContinue | ForEach-Object {
    $if = $_
    Write-Host "Adapter: $($if.InterfaceAlias) (ifIndex: $($if.InterfaceIndex))" -ForegroundColor Green
    if ($if.IPv4Address) {
        $if.IPv4Address | ForEach-Object {
            Write-Host ("  IPv4 : {0} /{1}" -f $_.IPAddress, $_.PrefixLength)
        }
    }
    if ($if.IPv6Address) {
        $if.IPv6Address | ForEach-Object {
            Write-Host ("  IPv6 : {0} /{1}" -f $_.IPAddress, $_.PrefixLength)
        }
    }
    if ($if.IPv4DefaultGateway) {
        $if.IPv4DefaultGateway | ForEach-Object {
            Write-Host ("  Gateway : {0}" -f $_.NextHop)
        }
    }
    if ($if.DnsServers) {
        Write-Host ("  DNS servers : {0}" -f ($if.DnsServers -join ", "))
    }
    Write-Host ""
}
Write-Host "`n"

# DHCP, DNS suffix, konekcijos profile
Write-Host "3) Papildoma informacija apie adapterius" -ForegroundColor Yellow
Get-NetIPInterface -ErrorAction SilentlyContinue |
  Select-Object ifIndex, InterfaceAlias, AddressFamily, Dhcp, AdvertiseDefaultRoute, RouterDiscovery |
  Format-Table -AutoSize
Write-Host "`n"

# Maršrutizacijos lentelė
Write-Host "4) Maršrutizacijos lentelė (routing table)" -ForegroundColor Yellow
Get-NetRoute -ErrorAction SilentlyContinue | Sort-Object -Property DestinationPrefix |
  Select-Object DestinationPrefix, NextHop, InterfaceAlias, RouteMetric |
  Format-Table -AutoSize
Write-Host "`n"

# ARP / kaimynai
Write-Host "5) ARP / kaimynų lentelė (neighbours)" -ForegroundColor Yellow
Get-NetNeighbor -ErrorAction SilentlyContinue |
  Select-Object ifIndex, InterfaceAlias, IPAddress, LinkLayerAddress, State |
  Format-Table -AutoSize
Write-Host "`n"

# Adapter statistika
Write-Host "6) Adapterių statistika" -ForegroundColor Yellow
Get-NetAdapterStatistics -ErrorAction SilentlyContinue |
  Select-Object Name, ReceivedUnicastPackets, SentUnicastPackets, ReceivedBytes, SentBytes |
  Format-Table -AutoSize
Write-Host "`n"

# Windows tinklo profilis ir ugniasienė
Write-Host "7) Tinklo profiliai ir ugniasienė" -ForegroundColor Yellow
Get-NetConnectionProfile -ErrorAction SilentlyContinue | Select-Object Name, InterfaceAlias, NetworkCategory, IPv4Connectivity, IPv6Connectivity
Write-Host ""
Get-NetFirewallProfile -ErrorAction SilentlyContinue | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction | Format-Table -AutoSize
Write-Host "`n"

# Fallback / papildoma informacija
Write-Host "8) Papildoma (ipconfig /all ir route print)" -ForegroundColor Yellow
Write-Host "---- ipconfig /all ----" -ForegroundColor DarkGray
ipconfig /all
Write-Host "`n---- route print ----" -ForegroundColor DarkGray
route print

# Bandymas gauti viešą IP (jei yra interneto ryšys)
Write-Host "`n9) Viešas IP (bandoma pasiekti aptarnavimo tašką)" -ForegroundColor Yellow
try {
    $public = Invoke-RestMethod -Uri "https://ipinfo.io/ip" -UseBasicParsing -ErrorAction Stop
    Write-Host ("Public IP: {0}" -f $public.Trim())
} catch {
    Write-Host "Public IP: negalima pasiekti (be interneto arba užblokuota)" -ForegroundColor DarkRed
}

Write-Host "`nPabaiga." -ForegroundColor Cyan
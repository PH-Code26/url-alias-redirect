$certPath = Join-Path $PSScriptRoot 'cert.pfx'
$aliases = Get-Content (Join-Path $PSScriptRoot 'aliases.json') -Raw | ConvertFrom-Json
$names = $aliases.PSObject.Properties.Name

if (Test-Path $certPath) {
    Write-Host "Certificate already exists, skipping."
    exit 0
}

$dnsParams = @()
$first = $true
foreach ($name in $names) {
    if ($first) {
        $cn = $name
        $first = $false
    }
    $dnsParams += $name
}

$cert = New-SelfSignedCertificate `
    -DnsName $dnsParams `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyUsage DigitalSignature, KeyEncipherment `
    -Type SSLServerAuthentication `
    -FriendlyName "URL-Alias-Redirect"

$password = ConvertTo-SecureString -String "alias123" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath $certPath -Password $password | Out-Null

Remove-Item "Cert:\CurrentUser\My\$($cert.Thumbprint)" -Force

Write-Host "Certificate generated: cert.pfx"
Write-Host "Domains: $($dnsParams -join ', ')"
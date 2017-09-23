#
# Fetches a https certificate from a url and
# returns the SHA1 thumbprint of the certificate with PowerShell
#
#example uri:  https://vcenterhost.corp.local:443
#returns something similar to: EF:FF:EB:D5:F8:89:89:1E:96:A3:6D:05:D9:D6:1B:45:23:DB:9B:3C
#

param([parameter(Mandatory=$true)][uri]$uri)

if (-Not ($uri.Scheme -eq "https"))
{
    Write-Error "You can only get keys for https addresses"
    exit 1
}

$request = [System.Net.HttpWebRequest]::Create($uri)

try
{
    #Make the request but ignore (dispose it) the response, since we only care about the service point 
    $request.GetResponse().Dispose()
}
catch [System.Net.WebException]
{
    if ($_.Exception.Status -eq [System.Net.WebExceptionStatus]::TrustFailure)
    {
        #We ignore trust failures, since we only want the certificate, and the service point is still populated at this point
    }
    else
    {
        #Let other exceptions bubble up, or write-error the exception and return from this method
        throw
    }
}

#The ServicePoint object should now contain the Certificate for the site.
$servicePoint = $request.ServicePoint
$certificate = $servicePoint.Certificate
$key = $servicePoint.Certificate

#Read the certificate
$certinfo = New-Object system.security.cryptography.x509certificates.x509certificate2($certificate)
#Get the SHA1 thumbprint and delimit it with ':'
$thumbParts = $certinfo.Thumbprint.ToCharArray()
$thumbParts2 = New-Object System.Collections.ArrayList
for ($i = 0; $i -lt $thumbParts.Length; $i = $i+2) {
    [Void]$thumbParts2.Add([string]$thumbParts[$i]+$thumbParts[$i+1])
}
[String]::Join(':',$thumbParts2.toarray([string]))
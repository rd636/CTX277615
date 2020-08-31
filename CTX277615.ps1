<#
	.SYNOPSIS
        Conduct file operations on NetScaler ADC instances via ADM API Proxy.
        *Requires Powershell v6+ for required REST CustomMethod support.

	.DESCRIPTION
        Uses the API Proxy feature of Application Delivery Manager (ADM) 
        to conduct automated operations.

        Benefits of using ADM as an API Proxy:

        Role Based Access enforcement 
          ADM validates all API requests against configured security
          and role-based access control (RBAC) policies. 

        Tennent Enforcement   
          ADM is tenant-aware and can ensures API activity does not 
          cross tenant boundaries.

        Centralized auditing 
          ADM maintains an audit log of all API activity related to 
          its managed instances.

        Session management
          ADM frees API clients from the task of having to maintain
          sessions with managed instances. 
	
	.FUNCTIONALITY
		Application Delivery Manager (ADM) v13.0
        NetScaler ADC (NS) v13.0

	.NOTES
        AUTHOR : Rick Davis
        EMAIL  : Rick.Davis@citrix.com
        DATE   : 28 AUG 2020

        NetScaler ADM as an API Proxy Server
        https://docs.citrix.com/en-us/netscaler-mas/12/mas-as-api-proxy-server.html

        To make ADM forward a request to a managed instance, include any one 
        of the following HTTP headers in the API request:

        _MPS_API_PROXY_MANAGED_INSTANCE_NAME   Name of the managed instance.
        _MPS_API_PROXY_MANAGED_INSTANCE_IP     IP address of the managed instance.
        _MPS_API_PROXY_MANAGED_INSTANCE_ID     ID of the managed instance.

        The minimum Role Based Access Policy must include the View setting for:
        Networks > API > Device_API_Proxy 

        Authorized ADM API users also obtain nsroot level instance authorization.
	
	.PARAMETER 
	    Guie input parameters.
    
    .VERSION
        1.0  Initial build.

    .LINK
        https://docs.citrix.com/en-us/netscaler-mas/12/mas-as-api-proxy-server.html
        https://stackoverflow.com/questions/32355556/powershell-invoke-restmethod-over-https

    .COPYRIGHT
        This sample code is provided to you as is with no representations, 
		warranties or conditions of any kind. You may use, modify and 
		distribute it at your own risk. CITRIX DISCLAIMS ALL WARRANTIES 
		WHATSOEVER, EXPRESS, IMPLIED, WRITTEN, ORAL OR STATUTORY, INCLUDING 
		WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
		PARTICULAR PURPOSE, TITLE AND NONINFRINGEMENT. Without limiting the 
		generality of the foregoing, you acknowledge and agree that (a) 
		the sample code may exhibit errors, design flaws or other problems, 
        possibly resulting in loss of data or damage to property; (b) it may 
		not be possible to make the sample code fully functional; and 
		(c) Citrix may, without notice or liability to you, cease to make 
		available the current version and/or any future versions of the sample 
		code. In no event should the code be used to support ultra-hazardous 
		activities, including but not limited to life support or blasting 
		activities. NEITHER CITRIX NOR ITS AFFILIATES OR AGENTS WILL BE LIABLE,
        UNDER BREACH OF CONTRACT OR ANY OTHER THEORY OF LIABILITY, FOR ANY 
		DAMAGES WHATSOEVER ARISING FROM USE OF THE SAMPLE CODE, INCLUDING 
		WITHOUT LIMITATION DIRECT, SPECIAL, INCIDENTAL, PUNITIVE, CONSEQUENTIAL 
		OR OTHER DAMAGES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
		Although the copyright in the code belongs to Citrix, any distribution 
		of the sample code should include only your own standard copyright 
		attribution, and not that of Citrix. You agree to indemnify and defend 
		Citrix against any and all claims arising from your use, modification 
		or distribution of the sample code.
#>
Set-StrictMode -Version 3
$VerbosePreference = "SilentlyContinue"                         #Continue or SilentlyContinue
# Load assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

<# This form was created using POSHGUI.com a free online gui designer for PowerShell #>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = New-Object System.Drawing.Point(800,800)
$Form.text                       = "CTX277615"
$Form.TopMost                    = $false

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "ADM IP Address"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(20,8)
$Label1.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "ADM User Name"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(230,8)
$Label2.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Password"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(394,8)
$Label3.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "NetScaler IP Address"
$Label4.AutoSize                 = $true
$Label4.width                    = 25
$Label4.height                   = 10
$Label4.location                 = New-Object System.Drawing.Point(18,85)
$Label4.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "Filename"
$Label5.AutoSize                 = $true
$Label5.width                    = 25
$Label5.height                   = 10
$Label5.location                 = New-Object System.Drawing.Point(232,85)
$Label5.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Label6                          = New-Object system.Windows.Forms.Label
$Label6.text                     = "File Location"
$Label6.AutoSize                 = $true
$Label6.width                    = 25
$Label6.height                   = 10
$Label6.location                 = New-Object System.Drawing.Point(396,85)
$Label6.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ADM_SVR                         = New-Object system.Windows.Forms.TextBox
$ADM_SVR.multiline               = $false
$ADM_SVR.text                    = "192.168.200.250"
$ADM_SVR.width                   = 200
$ADM_SVR.height                  = 20
$ADM_SVR.location                = New-Object System.Drawing.Point(18,30)
$ADM_SVR.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ADM_UNAME                       = New-Object system.Windows.Forms.TextBox
$ADM_UNAME.multiline             = $false
$ADM_UNAME.text                  = "nsroot"
$ADM_UNAME.width                 = 150
$ADM_UNAME.height                = 20
$ADM_UNAME.location              = New-Object System.Drawing.Point(230,30)
$ADM_UNAME.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ADM_PWD                         = New-Object system.Windows.Forms.MaskedTextBox
$ADM_PWD.PasswordChar           = '*'
$ADM_PWD.multiline               = $false
$ADM_PWD.text                    = "nsroot"
$ADM_PWD.width                   = 150
$ADM_PWD.height                  = 20
$ADM_PWD.location                = New-Object System.Drawing.Point(392,30)
$ADM_PWD.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$NetScaler                       = New-Object system.Windows.Forms.TextBox
$NetScaler.multiline             = $false
$NetScaler.text                  = "192.168.200.220"
$NetScaler.width                 = 200
$NetScaler.height                = 20
$NetScaler.location              = New-Object System.Drawing.Point(18,110)
$NetScaler.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$file_name                       = New-Object system.Windows.Forms.TextBox
$file_name.multiline             = $false
$file_name.text                  = "httpd.conf"
$file_name.width                 = 150
$file_name.height                = 20
$file_name.location              = New-Object System.Drawing.Point(230,110)
$file_name.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$file_location                   = New-Object system.Windows.Forms.TextBox
$file_location.multiline         = $false
$file_location.text              = '/nsconfig'
$file_location.width             = 250
$file_location.height            = 20
$file_location.location          = New-Object System.Drawing.Point(392,110)
$file_location.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button_doit                     = New-Object system.Windows.Forms.Button
$Button_doit.text                = "DO IT"
$Button_doit.width               = 60
$Button_doit.height              = 30
$Button_doit.location            = New-Object System.Drawing.Point(158,152)
$Button_doit.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Options_box1                    = New-Object system.Windows.Forms.ComboBox
$Options_box1.text               = ""
@('GET','POST','DELETE') | Foreach-Object {[void] $Options_box1.Items.Add($_)}
$Options_box1.SelectedIndex      = 0
$Options_box1.width              = 100
$Options_box1.height             = 20
$Options_box1.location           = New-Object System.Drawing.Point(18,155)
$Options_box1.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $true
$TextBox1.width                  = 764
$TextBox1.height                 = 580
$TextBox1.ScrollBars             = "Vertical" 
$TextBox1.ReadOnly               = $false
$TextBox1.location               = New-Object System.Drawing.Point(18,200)
$TextBox1.Font                   = New-Object System.Drawing.Font('Courier New',10)

$Status                          = New-Object system.Windows.Forms.Label
$Status.text                     = ""
$Status.AutoSize                 = $true
$Status.width                    = 70
$Status.height                   = 25
$Status.location                 = New-Object System.Drawing.Point(286,155)
$Status.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Secure                          = New-Object system.Windows.Forms.CheckBox
$Secure.text                     = "SSL Encrypted"
$Secure.checked               = $true
$Secure.AutoSize                 = $false
$Secure.width                    = 200
$Secure.height                   = 20
$Secure.location                 = New-Object System.Drawing.Point(565,25)
$Secure.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$ADM_Proxy                       = New-Object system.Windows.Forms.CheckBox
$ADM_Proxy.text                  = "Via ADM"
$ADM_Proxy.checked               = $true
$ADM_Proxy.AutoSize              = $false
$ADM_Proxy.width                 = 95
$ADM_Proxy.height                = 20
$ADM_Proxy.location              = New-Object System.Drawing.Point(565,75)
$ADM_Proxy.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$SSL_NoCertCheck                       = New-Object system.Windows.Forms.CheckBox
$SSL_NoCertCheck.text                  = "No Cert Check: PSv6+ required"
$SSL_NoCertCheck.checked               = $false
$SSL_NoCertCheck.AutoSize              = $false
$SSL_NoCertCheck.width                 = 235
$SSL_NoCertCheck.height                = 20
$SSL_NoCertCheck.location              = New-Object System.Drawing.Point(565,50)
$SSL_NoCertCheck.Font                  = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Form.controls.AddRange(@($ADM_SVR,$ADM_UNAME,$ADM_PWD,$NetScaler,$file_name,$file_location,$Button_doit,$Options_box1,$Label1,$Label2,$Label3,$Label4,$Label5,$Label6,$TextBox1,$Status,$Secure,$ADM_Proxy,$SSL_NoCertCheck))

#####  FUNCTIONS
function NitroCall {  
    param([hashtable]$global:array)
    Write-Verbose ">>> $($MyInvocation.MyCommand) $(Split-Path $array.uri -leaf)"
    # switch on ADM Proxy checkbox to use ADM_SVR or Direct 
    $array.uri         = $array.uri.insert(0, $protocol+'://'+$hostname )
    $array.ContentType = 'application/json';  
    if ( (Split-Path $array.uri -leaf) -eq 'login' ) { 
            $array.SessionVariable = "global:myWebSession"
        } elseif ( (Split-Path $array.uri -leaf) -eq 'logout' ) { 
            $array.WebSession      = $global:myWebSession
            $array.WebSession.Headers.Remove("_MPS_API_PROXY_MANAGED_INSTANCE_IP")  
            $array.WebSession.Headers.Remove("_MPS_API_PROXY_MANAGED_INSTANCE_ID")
            $array.WebSession.Headers.Remove("_MPS_API_PROXY_MANAGED_INSTANCE_NAME")
        } else {
            $array.WebSession      = $global:myWebSession
        } 
    try {
        if ($SSL_NoCertCheck.checked -eq $true -and $PSVersionTable.PSVersion.Major -gt 5) { 
            Invoke-RestMethod @array -TimeoutSec 2 -SkipCertificateCheck
        } else {
            Invoke-RestMethod @array -TimeoutSec 2 
        }
    } catch { 
        $Status.text = $_  
    }
    return
}

function _login_ADM {
    $jobj = ConvertFrom-Json '{"login":{"username":"nsroot","password":"nsroot"}}'
    $jobj.login.username = $ADM_UNAME.text 
    $jobj.login.password = $ADM_PWD.text
    NitroCall @{    'uri'          = '/nitro/v1/config/login' 
                    'Method'	   = 'POST'
                    'Body'         = 'object='+(ConvertTo-JSON $jobj)
                }|out-null
    try {
        write-host "$($myWebSession.Cookies.GetCookies($array.uri).name) = $($myWebSession.Cookies.GetCookies($array.uri).value)"
    }
    catch { return 1 }
}

function _login_NetScaler {
    $jobj = ConvertFrom-Json '{"login":{"username":"nsroot","password":"nsroot"}}'
    $jobj.login.username = $ADM_UNAME.text 
    $jobj.login.password = $ADM_PWD.text
    NitroCall @{    'uri'          = '/nitro/v1/config/login' 
                    'Method'	   = 'POST'
                    'Body'         = ConvertTo-JSON $jobj
                }|out-null
}

function _logout_ADM {
    $jobj = ConvertFrom-Json '{"logout":{"sessionid":"String_value"}}'
    $jobj.logout.sessionid = $($myWebSession.Cookies.GetCookies($array.uri).value)
    NitroCall @{    'uri'          = '/nitro/v1/config/logout' 
                    'Method'	   = 'DELETE'
                    'Body'         = ConvertTo-JSON $jobj
                    'Headers'      = @{_MPS_API_PROXY_MANAGED_INSTANCE_IP=$($NetScaler.text)}  
                }|out-null
}

function _logout_NetScaler {
    NitroCall @{    'uri'          = '/nitro/v1/config/logout' 
                    'Method'	   = 'POST'
                    'Body'         = '{"logout":{}}'
                    'Headers'      = @{}
                }|out-null
}

function _file_get {
    # GET /nitro/v1/config/systemfile? args=filename: <String_value> , filelocation:<String_value>
    $apiCall = NitroCall @{ 'uri'     =  '/nitro/v1/config/systemfile/'+([System.Web.HTTPUtility]::UrlEncode($file_name.text))+'?args=filelocation:'+([System.Web.HTTPUtility]::UrlEncode($file_location.text))
                            'Method'  = 'GET' 
                            'Headers' = @{_MPS_API_PROXY_MANAGED_INSTANCE_IP=$($NetScaler.text)}
                        }     
    $TextBox1.Text = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($apiCall.systemfile.filecontent))  
}

function _file_add {
    $jobj = ConvertFrom-Json '{"systemfile":{"filename":"String_value","filecontent":"String_value","filelocation":"String_value","fileencoding":"BASE64"}}'
    $jobj.systemfile.filename     = $file_name.text
    $jobj.systemfile.filelocation = $file_location.text
    $jobj.systemfile.filecontent  = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($TextBox1.Text))
    $apiCall = NitroCall @{ 'uri'     =  '/nitro/v1/config/systemfile'
                            'Method'  = 'POST' 
                            #'CustomMethod' = 'ADD'
                            'Headers' = @{_MPS_API_PROXY_MANAGED_INSTANCE_IP=$($NetScaler.text)} 
                            'Body'    = ConvertTo-JSON $jobj
                        }     
}

function _file_delete {
    $apiCall = NitroCall @{ 'uri'     =  '/nitro/v1/config/systemfile/'+([System.Web.HTTPUtility]::UrlEncode($file_name.text))+'?args=filelocation:'+([System.Web.HTTPUtility]::UrlEncode($file_location.text))
                            'Method'  = 'DELETE' 
                            'Headers' = @{_MPS_API_PROXY_MANAGED_INSTANCE_IP=$($NetScaler.text)}
                        }     
}

function _main {
    $Status.Text = ""
    
    switch ($Secure.checked) {
        $true  { $protocol = 'https' }
        $false { $protocol = 'http'  }
    }

    ## Login
    switch ($ADM_Proxy.checked) {
        $true  { $hotname = $hostname = $ADM_SVR.text     
                 _login_ADM
                }
        $false { $hostname = $hostname = $NetScaler.text  
                 _login_NetScaler}
    }
    if ($Status.text -ne '') { return } # Test if the previous action resulted in an error

    ## Actions
    switch ($Options_box1.Text) {
        'GET' { _file_get 
                return
            }
        'POST' { _file_add 
                if ($Status.text -ne '') { return } # Test and abort if the previous action resulted in an error
                $Status.text = 'File posted' # Update status
                return
            }
        'DELETE' {
            $msgBoxInput =  [System.Windows.Forms.MessageBox]::Show('This will delete the file. Are you sure?','WARNING','YesNoCancel','Error')
            switch  ($msgBoxInput) {
                'Yes' { 
                    _file_delete
                    if ($Status.text -ne '') { return } # Test and abort if the previous action resulted in an error
                    $Status.text = 'File deleted' # Update status
                    return
                }
                'No' {  $Status.text = 'operation canceled' 
                        return 
                    }
                'Cancel' {  $Status.text = 'operation canceled' 
                            return 
                        }   
            }
        }
    }
    if ($Status.text -ne '') { return } # Test if the previous action resulted in an error

    ## Logout
    switch ($ADM_Proxy.checked) {
        $true  { _logout_ADM       }
        $false { _logout_NetScaler }
    }

}

##### MAIN
if ($SSL_NoCertCheck.checked -eq $true -and $PSVersionTable.PSVersion.Major -lt 6) {
add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;

            public class IDontCarePolicy : ICertificatePolicy {
            public IDontCarePolicy() {}
            public bool CheckValidationResult(
                ServicePoint sPoint, X509Certificate cert,
                WebRequest wRequest, int certProb) {
                return true;
            }
        }
"@
[System.Net.ServicePointManager]::CertificatePolicy = new-object IDontCarePolicy
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
}

$Button_doit.Add_Click({_main})
$result = $Form.ShowDialog()

exit

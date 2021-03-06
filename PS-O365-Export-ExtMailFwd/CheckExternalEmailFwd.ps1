﻿# 
# Check for External Email Forwarding and Export to File.
#
# Latest Version @ https://github.com/activex/O365-Azure-PowerShell-Repo
#
# Original Script by Elliot Munro - https://gcits.com/
# Adapted to to work with individual tenants by removing partner onlt cmd-lets
#
# For Modern Auth Requires: Install-Module –Name ExchangeOnlineManagement
#
# Output at:  C:\temp\yyyymmdd_ExternalForward.csv
# 
# v0.2 - 03-12-2020 - Removed basic auth, ExchangeOnlineManagement, cleaned formatting
# v0.1 - 30-11-2020 - Removed customer* fields in output, added date to filename
#

    Write-Host "Connecting..."
    Connect-ExchangeOnline

    Write-Host "Checking..."
    $mailboxes = $null
    $mailboxes = Get-Mailbox -ResultSize Unlimited
    $domains = Get-AcceptedDomain
    $CurrentDate = Get-Date -Format "yyyymmdd"
 
    foreach ($mailbox in $mailboxes) {
 
        $forwardingSMTPAddress = $null
  #      Write-Host "Checking forwarding for $($mailbox.displayname) - $($mailbox.primarysmtpaddress)"
        $forwardingSMTPAddress = $mailbox.forwardingsmtpaddress
        $externalRecipient = $null
        if($forwardingSMTPAddress){
                $email = ($forwardingSMTPAddress -split "SMTP:")[1]
                $domain = ($email -split "@")[1]
                if ($domains.DomainName -notcontains $domain) {
                    $externalRecipient = $email
                }
 
            if ($externalRecipient) {
                Write-Host "$($mailbox.displayname) - $($mailbox.primarysmtpaddress) forwards to $externalRecipient" -ForegroundColor Yellow
 
                $forwardHash = $null
                $forwardHash = [ordered]@{
                    DisplayName        = $mailbox.DisplayName
                    PrimarySmtpAddress = $mailbox.PrimarySmtpAddress
                    ExternalRecipient  = $externalRecipient
                }
                $ruleObject = New-Object PSObject -Property $forwardHash
                $ruleObject | Export-Csv -Path "C:\temp\${CurrentDate}_ExternalForward.csv" -NoTypeInformation -Append
            }
        }
    }

    Write-Host "Exported to: C:\temp\${CurrentDate}_ExternalForward.csv"
$Password = "basepass123!"  # Default password for newly created accounts
$filepath = Read-Host "What is the path to the text file?: " # Grabbing text file's location in order to parse through it for data extraction.
$fileContent = Get-Content -Path $filepath

# New-ADOrganizationalUnit -Name Marketing -ProtectedFromAccidentalDeletion $true
# $ou = "Marketing"

function add_user {
    <#
    Note: If you decide to make your OUs through this script and assign users accordingy, modify the script so that it matches your interest and replace
    $path = "OU=Test_users ..." with $path = "OU=$ou ..." or feel free to use CSVDE.
    This function iterates through each line of the text file and extracts info in the following format and CREATES users under the specified Organizational Unit:
    var path = path inside DC server to append these users to. Make sure that these infos are replaced when you are using it yourself.
    var pass = converts default password assigned above and assigns it to pass variable.
    var first = first name or position 0 of the index (first word) and make it all lowercase
    var last = last name or position 1 of the index (second word or in this case last) and make it all lowercase
    var username = combines firstname and last name in the following format: John.Doe
    #>
    foreach($line in $fileContent) {
        $path = "OU=Test_Users,DC=homelab,DC=com"
        $pass = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $first = $line.split(" ")[0].ToLower()
        $last = $line.split(" ")[1].ToLower()
        $username = "$first.$last"
        Write-Host "Creating New User: $($username)"
        New-AdUser -AccountPassword $pass -GivenName $first -Surname $last -Name $line -SamAccountName $username -UserPrincipalName $username -Enabled $True -Path $path -ChangePasswordAtLogon $true
}}
function delete_user {
    <#
    This function iterates through each line of the text file and extracts info in the following format and DELETES users:
    var first = first name or position 0 of the index (first word) and make it all lowercase
    var last = last name or position 1 of the index (second word or in this case last) and make it all lowercase
    var username = combines firstname and last name in the following format: John.Doe
    #>
    foreach($line in $fileContent) {
        $first = $line.split(" ")[0].ToLower()
        $last = $line.split(" ")[1].ToLower()
        $username = "$first.$last"
        Write-Host "Removing User: $($username)"
        Remove-AdUser -Identity $username
    }
}

while ($true){
$user_input = Read-Host "What would you like to do (Enter 1 for add or 2 for remove) ?`n1. Add users to an AD OU?`n2. Remove users from an AD OU?`n"

if ($user_input -eq 1) {
    add_user
    }

elseif ($user_input -eq 2) {
    delete_user
    }

else { write-Host "Invalid option"}}

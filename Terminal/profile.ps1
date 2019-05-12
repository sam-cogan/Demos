#Import required modules
Import-Module 'posh-git'
Import-Module 'oh-my-posh'
Import-Module 'Get-ChildItemColor'
Import-module 'AzureUtil'

#Set Default user for oh-my-posh to avoid username in prompt
$DefaultUser = 'SamCogan'

# Default the prompt to agnoster oh-my-posh theme
Set-Theme agnoster
# Set locaion
set-location "D:\Repos"

# Ensure that Get-ChildItemColor is loaded
Import-Module Get-ChildItemColor

# Set l and ls alias to use the new Get-ChildItemColor cmdlets
Set-Alias l Get-ChildItemColor -Option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope
Set-Alias dir Get-ChildItemColorFormatWide -Option AllScope

#utility functions

function repos {set-location "D:\Repos" }
function docs {set-location "C:\Users\SamCogan\OneDrive - Sam Cogan\"}


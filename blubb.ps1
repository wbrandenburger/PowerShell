
#------------------------------------------------------------------------------
#   Open-Profile
#------------------------------------------------------------------------------
Function Global:Show-HostColors
{
    $Colors = [Enum]::GetValues([System.ConsoleColor])
    Foreach ($BgColor in $Colors)
    {
        Foreach ($FgColor in $Colors) 
        { 
            Write-Host "$FgColor|"  -ForegroundColor $FgColor -BackgroundColor $BgColor -NoNewLine 
        }
        Write-Host " on $BgColor"
    }
}

# [Inherit HashTable](https://www.hernanjlarrea.com/index.php/extending-hashtables-functionalities-in-powershell-by-using-classes/)
# [PowerShell Classes I](https://overpoweredshell.com/Introduction-to-PowerShell-Classes/)
# [PowerShell Classes II](https://www.sapien.com/blog/2016/03/16/inheritance-in-powershell-classes/)
######GENERAL CLASS!!!!
# =============================================================================
#    Class HashTableList : System.Collections.HashTable
# =============================================================================
Class HashTableList : System.Collections.HashTable
{

    [Void] ExtAdd ([System.Object[]] $Input_Keys, [System.Object[]] $Input_Values)
    {
        $This.ExtAdd( $Input_Keys, $Input_Values, $True)
    }

    [Void] ExtAdd ([System.Object[]] $Input_Keys, [System.Object[]] $Input_Values, [Bool] $Strict)
    {
        ForEach ($Input_Keys_Item in $Input_Keys)    
        {
            If( -not ($This.Keys -contains $Input_Keys_Item) ) {
                $This.Add($Input_Keys_Item,[System.Collections.ArrayList]::New())
            }

            ForEach ($Input_Values_Item in $Input_Values) 
            {
                If ( ($This[$Input_Keys_Item] -contains $Input_Values_Item) -and $Strict) 
                {
                    Continue
                }
                $This[$Input_Keys_Item].Add($Input_Values_Item)
            }
        }
    }

    [Void] ExtRemove ([System.Object[]] $Input_Keys, [System.Object[]] $Input_Values)
    {
        ForEach ($Input_Keys_Item in $Input_Keys)    
        {
            If ($This.Keys -contains $Input_Keys_Item) 
            {
                ForEach ($Input_Values_Item in $Input_Values) 
                {
                    Do 
                    {
                        $This[$Input_Keys_Item].Remove($Input_Values_Item)
                    }
                    While ($This[$Input_Keys_Item] -contains $Input_Values_Item)
                }
                If ($This[$Input_Keys_Item].Count -eq 0) 
                {
                    $This.Remove($Input_Keys_Item)
                }
            }
        }
    }

    [System.Object] ConvertToObject()
    {
        Return ($This.Keys | ForEach-Object { [PSCustomObject] @{
                    GroupProfile = $_
                    Package = $This[$_]
                }})
    }
}

# =============================================================================
#    Class Progress
# =============================================================================
Class Progress
{
    [System.String] $Activity
    [System.String] $Status
    [System.Int32] $Num_Ops
    [System.Int32] $Idx_Ops
    
    Progress(
        [System.String] $Activity,
        [System.String] $Status,
        [System.Int32] $Num_Ops
    )
    {
        $This.Activity = $Activity
        $This.Status = $Status
        $This.Num_Ops = $Num_Ops
        $This.Idx_Ops = 0;
    }

    [Void] ShowProgress()
    {
        Write-Progress -Activity $This.Activity -Status $This.Status -PercentComplete ($This.Idx_Ops/$This.Num_Ops*100)
        $This.Idx_Ops++
    }

}

#------------------------------------------------------------------------------
#   Test-Verb
#------------------------------------------------------------------------------
Function Global:Test-Verb
{
    [CmdletBinding(PositionalBinding=$True)]
    
    [OutputType([System.Object])]
    
    Param
    (
        [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True,HelpMessage="Verb which will be tested being a member of approved PowerShell verbs")]
        [Alias("Verb")]
        [String] $Input_Verb   
    )
    
    Process
    {
        Return Get-Verb | Where-Object {$_.Verb -eq $Input_Verb }
    }
    
}

# #------------------------------------------------------------------------------
# #   Test-Bool
# #------------------------------------------------------------------------------
# Function Global:Test-Bool
# {
#     [CmdletBinding(PositionalBinding=$True)]
    
#     [OutputType([Bool])]
    
#     Param
#     (
#         [Parameter(Position=0, Mandatory=$True, HelpMessage="String which will be tested having a boolean value")]
#         [Alias("Value")]
#         [String] $Input_Value,

#         [Parameter(Position=1, Mandatory=$False, HelpMessage="Switch - Checking whether the testted string has the value false.")]
#         [Alias("TestFalse")]
#         [Switch] $Switch_TestFalse = $True
#     )

#     Process
#     {
#         Return ($Switch_False -eq [Regex]::IsMatch($Input_Value,"^1$")) -or ($Switch_False -eq [Regex]::IsMatch($Input_Value,"true",1))
#     }
# }

#------------------------------------------------------------------------------
#   Start-Profile
#------------------------------------------------------------------------------
Function Global:Start-Profile
{

    Param
    (
    )

    $UserProfile.StartProfile()
}

#------------------------------------------------------------------------------
#   Open-Profile
#------------------------------------------------------------------------------
Function Global:Open-Profile
{

    Param
    (
    )

    $UserProfile.OpenProfile()
}

# =============================================================================
#    Define Global Variables
# =============================================================================

    # Set Modules Path
        $PSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath")
        $PSModulePath += ";$env:Home\PSModules"
        [Environment]::SetEnvironmentVariable("PSModulePath", $PSModulePath)

    # Initialize object of class profile
        $Global:UserProfile = [Profile]::New()

    # Set location to %Home%
        $UserProfile.SetPathHome()

    # Check available packages
        $UserProfile.CheckPackages()

    # Clear Variables
        Remove-Variable -Name PSModulePath
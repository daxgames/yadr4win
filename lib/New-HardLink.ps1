Function New-HardLink {
    <#
        .SYNOPSIS
            Creates a hard link to a file

        .DESCRIPTION
            Creates a hard link to a file as an alternative to mklink.exe

        .PARAMETER Path
            Name of the file that you will reference with a hard link.

        .PARAMETER HardLink
            Name of the hard link to create. Can be a full path/unc or just the name.
            If only a name is given, the hard link will be created on the current directory that the
            function is being run on.

        .NOTES
            Name: New-HardLink
            Author: Boe Prox
            Created: 15 Jul 2013


        .EXAMPLE
            New-HardLink -Path "C:\users\admin\downloads\file.txt" -HardLink "C:\users\admin\desktop\file"

            HardLink                         Target                   
            -------                          ------                   
            C:\Users\admin\Desktop\file      C:\Users\admin\Downloads\file.txt

            Description
            -----------
            Creates a hard link to file.txt called file on the desktop.
    #>
    [cmdletbinding(
        SupportsShouldProcess=$True
    )]
    Param (
        [parameter(Position=0,ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,Mandatory=$True)]
        [ValidateScript({
            If (Test-Path $_ -PathType Leaf) {$True} Else {
                Throw "`'$_`' doesn't exist or isn't a file!"
            }
        })]
        [string]$Path,
        [parameter(Mandatory=$True)]
        [string]$HardLink
    )
    Begin {
        Try {
            $null = [mklink.hardlink]
        } Catch {
            Add-Type @"
            using System;
            using System.Runtime.InteropServices;
 
            namespace mklink
            {
                public class hardlink
                {
                    [DllImport("Kernel32.dll")]
                    public static extern bool CreateHardLink(string lpFileName,string lpExistingFileName,IntPtr lpSecurityAttributes);
                }
            }
"@
        }
    }
    Process {
        #Assume target Symlink is on current directory if not giving full path or UNC
        If ($Name -notmatch "^(?:[a-z]:\\)|(?:\\\\\w+\\[a-z]\$)") {
            $Name = "{0}\{1}" -f $pwd,$HardLink
        }
        If ($PScmdlet.ShouldProcess($Path,'Create Hard Link')) {
            Try {
                $return = [mklink.hardlink]::CreateHardLink($HardLink,$Path,[intptr]::Zero)
                If ($return) {
                    $object = New-Object PSObject -Property @{
                        HardLink = $HardLink
                        Target = $Path
                    }
                    $object.pstypenames.insert(0,'System.File.HardLink')
                    $object
                } Else {
                    Throw "Unable to create hard link!"
                }
            } Catch {
                Write-warning ("{0}: {1}" -f $path,$_.Exception.Message)
            }
        }
    }
 }

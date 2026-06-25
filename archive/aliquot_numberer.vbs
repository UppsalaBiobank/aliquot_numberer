' NAME:	aliquot_numberer.vbx
' AUTHOR: Henrik Vestin Uppsala Biobank
' DATE: 2021 03 15
' HISTORY: 1.01 initial version
'		   
'		   
' COMMENT: Utgå från Sjöberg import för att skapa alikvotnumrering.
'
'==================================================================

Option Explicit ' Force explicit variable declaration.

Dim FileLocation
Dim FileDestination
Dim objFSO
Dim objRead
Dim objWrite
Dim strContent
Dim arrLines
Dim x
Dim arrLineValues
Dim newLine
Dim currentKeyValue
Dim previousKeyValue
Dim aliquoteValue
Dim lineNum

Set objFSo = CreateObject("Scripting.FileSystemObject") ' function to crete an object of a specified type

'FileLocation = "P:\Biobank\Ongoing\FreezerPro_Intern\Sjöberg\1 - Import\Import prov" 
FileLocation = "C:\temp\Freezerpro_aliquote\" ' test-filepath
FileLocation = FileLocation & "210310 SJo samtliga prov.csv"

'FileDestination = "P:\Biobank\Ongoing\FreezerPro_Intern\Sjöberg\1 - Import\Import prov"
FileDestination = "C:\temp\Freezerpro_aliquote\"
FileDestination = FileDestination & Date & "-SJo_med_alikvot.csv"
wscript.Echo FileDestination

Set objRead = objFSO.OpenTextFile(FileLocation, 1 , False) ' open csv
objRead.SkipLine ' skip first line in file since it contains column headers
strContent = objRead.ReadAll 'read file
objRead.Close
arrLines = Split(strContent, vbCrLf) 'split creates an one-dimensional array

Set objWrite = objFSO.CreateTextFile(FileDestination, True) ' Create file
objWrite.WriteLine "ParentID;ALIQUOT;() Provnummer;Sample Source;() Provtagningsdatum;() Ankomstdatum;() Nedfrysningsdatum;() Besök;Sample Type;Key;Volume;Antal miljoner celler;Kommentar;Frys;Level1;Level2;Level3;Level4;Box;Position;"
aliquoteValue = 0	
previousKeyValue = ""
For x = 0 to Ubound(arrLines) -1 'iterate array until end, -1 is because the exported csv had an empty line.
	arrLineValues = Split(arrlines(x), ";") 'another array split at each ;
	currentKeyValue = arrLineValues(9) ' grab keyvalue from current line in arrLinesValues
	
	If currentKeyValue = previousKeyValue then 'compare keyvalues to determine what aliquote number to set.
		aliquoteValue = aliquoteValue
		arrLineValues(1) = aliquoteValue
	Else
		aliquoteValue = aliquoteValue + 1
		arrLineValues(1) = aliquoteValue
	End If
newLine = Join(arrLineValues, ";") ' Join array into string
objWrite.WriteLine newLine 'insert the string to the outputfile
	
previousKeyValue = currentKeyValue ' used for comparison in the if statement
	
lineNum = lineNum + 1
wscript.Echo "Line #" & lineNum ' dont mind me i just count lines.
Next
objWrite.Close ' close the file

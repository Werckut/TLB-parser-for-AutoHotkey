#Requires AutoHotkey v2.0

class TlbParser {
    static Scan(tlbFile) {
        if !FileExist(tlbFile)
            throw Error("Файл не найден: " tlbFile)
            
        binData := FileRead(tlbFile, "RAW")
        bufSize := binData.Size
        
        ; Проверяем сигнатуру MSFT
        magic := NumGet(binData, 0, "UInt")
        if (magic != 0x5446534D)
            throw Error("Файл не является валидной библиотекой типов MSFT/OLE.")
            
        stringTableOffset := NumGet(binData, 0x28, "Int")
        if (stringTableOffset <= 0 || stringTableOffset >= bufSize) {
            stringTableOffset := 0
            Loop bufSize - 4 {
                if (NumGet(binData, A_Index - 1, "UInt") == 0x5446534D) {
                    stringTableOffset := NumGet(binData, A_Index + 39, "Int")
                    break
                }
            }
        }
        
        extractedStrings := []
        currentStr := ""
        startPos := stringTableOffset ? stringTableOffset : 0
        endPos := bufSize
        
        Loop endPos - startPos {
            byte := NumGet(binData, startPos + A_Index - 1, "UChar")
            if (byte >= 48 && byte <= 57) || (byte >= 65 && byte <= 90) || (byte >= 97 && byte <= 122) || (byte == 92) || (byte == 95) {
                currentStr .= Chr(byte)
            } else {
                if (StrLen(currentStr) >= 3) {
                    extractedStrings.Push(currentStr)
                }
                currentStr := ""
            }
        }
        
        classesMap := Map()
        currentClass := "GlobalMethods"
        classesMap[currentClass] := Map()
        blacklist := Map("void",1,"int",1,"long",1,"double",1,"float",1,"char",1,"short",1,"hresult",1,"bstr",1,"unknown",1,"idispatch",1,"stdole",1)
        
        for str in extractedStrings {
            cleanStr := RegExReplace(str, "(WWW|WW|W|\d+)$")
            if (cleanStr == "QueryInterface" || cleanStr == "AddRef" || cleanStr == "Release" || StrLen(cleanStr) < 3 || blacklist.Has(StrLower(cleanStr)))
                continue
                
            if RegExMatch(cleanStr, "^I[A-Z][a-zA-Z0-9_]+$") {
                currentClass := cleanStr
                if !classesMap.Has(currentClass)
                    classesMap[currentClass] := Map()
                continue
            }
            
            if RegExMatch(cleanStr, "^[a-zA-Z][a-zA-Z0-9_]+$") {
                classesMap[currentClass][cleanStr] := true
            }
        }
        
        return classesMap
    }
    
    static GenerateClassCode(className, methodsMap) {
        if (methodsMap.Count == 0 || className == "GlobalMethods")
            return ""
            
        code := "/**`n * Класс " className "`n */`n"
        code .= "class " className " {`n"
        for methodName, _ in methodsMap {
            code .= "    /**`n     * @method " methodName "`n     */`n"
            code .= "    " methodName "(*) => `"`"`n`n"
        }
        code .= "}`n`n"
        return code
    }
}
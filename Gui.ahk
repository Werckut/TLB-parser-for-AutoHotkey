#Requires AutoHotkey v2.0

class TlbGui {
    static MainGui := ""
    static FileList := []
    static LV := ""
    static OptSplit := ""
    static OptSingle := ""
    static CustomNameEdit := ""
    static ProgBar := ""
    static StatusText := ""
    static MyContextMenu := ""
    
    static Show() {
        this.MainGui := Gui("+Resize", "Универсальный Конвертер TLB в AHK v2")
        this.MainGui.SetFont("s10", "Segoe UI")
        
        this.MainGui.Add("GroupBox", "w560 h180", " Список файлов для конвертации (.tlb) ")
        this.LV := this.MainGui.Add("ListView", "xp+15 yp+25 w530 h100 Grid", ["Имя файла", "Путь"])
        this.LV.ModifyCol(1, 150)
        this.LV.ModifyCol(2, 360)
        
        this.LV.OnEvent("ContextMenu", (guiCtrl, itemIndex, isRightClick, x, y) => this.OnLVContextMenu(itemIndex))
        
        this.MyContextMenu := Menu()
        this.MyContextMenu.Add("Удалить элемент", (itemName, itemPos, menuObj) => this.OnContextDelete())
        
        btnBrowse := this.MainGui.Add("Button", "w120 h30 xp yp+110", "Добавить файлы")
        btnBrowse.OnEvent("Click", (*) => this.OnBrowse())
        
        btnClear := this.MainGui.Add("Button", "w120 h30 xp+130 yp", "Очистить список")
        btnClear.OnEvent("Click", (*) => this.OnClear())
        
        this.MainGui.Add("GroupBox", "x10 y200 w560 h110", " Настройки экспорта ")
        this.OptSingle := this.MainGui.Add("Radio", "Checked xp+15 yp+25", "Объединить всё в один файл")
        this.OptSingle.OnEvent("Click", (*) => this.CustomNameEdit.Enabled := true)
        
        this.OptSplit := this.MainGui.Add("Radio", "xp+230 yp", "Разбить каждый класс в отдельный файл")
        this.OptSplit.OnEvent("Click", (*) => this.CustomNameEdit.Enabled := false)
        
        this.MainGui.Add("Text", "x25 yp+35", "Имя выходного файла (для объединения):")
        this.CustomNameEdit := this.MainGui.Add("Edit", "w250 xp+250 yp-3", "tlb_exported_auto.ahk")
        
        this.ProgBar := this.MainGui.Add("Progress", "x10 y325 w560 h20 cGreen Range0-100", 0)
        this.StatusText := this.MainGui.Add("Text", "x10 y350 w560 r1", "Нажмите ПКМ по строке в таблице для удаления. Поддерживается Drag & Drop.")
        
        btnConvert := this.MainGui.Add("Button", "x200 y380 w180 h40 Default", "ЗАПУСТИТЬ КОНВЕРТАЦИЮ")
        btnConvert.OnEvent("Click", (*) => this.OnConvert())
        
        this.MainGui.OnEvent("DropFiles", (guiObj, ctrlObj, fileArray, *) => this.OnDrop(fileArray))
        this.MainGui.OnEvent("Close", (*) => ExitApp())
        
        this.MainGui.Show("w580 h435")
    }
    
    static OnLVContextMenu(itemIndex) {
        if (itemIndex > 0) { 
            this.LV.Modify(itemIndex, "Select Focus") 
            this.MyContextMenu.Show()
        }
    }
    
    static OnContextDelete() {
        focusedRow := this.LV.GetNext(0, "F")
        if (focusedRow > 0) {
            this.FileList.RemoveAt(focusedRow)
            this.LV.Delete(focusedRow)
            this.StatusText.Text := "Элемент удален из списка."
        }
    }
    
    static OnBrowse() {
        SelectedFiles := FileSelect("M3", , "Выберите библиотеки типов", "Библиотеки типов (*.tlb)")
        if !SelectedFiles
            return
        this.AddFilesToList(SelectedFiles)
    }
    
    static OnDrop(fileArray) {
        validFiles := []
        for file in fileArray {
            if (SubStr(file, -4) = ".tlb")
                validFiles.Push(file)
        }
        if (validFiles.Length > 0)
            this.AddFilesToList(validFiles)
    }
    
    static AddFilesToList(files) {
        for file in files {
            alreadyExists := false
            for existingPath in this.FileList {
                if (existingPath = file) {
                    alreadyExists := true
                    break
                }
            }
            if !alreadyExists {
                name := ""
                SplitPath(file, &name)
                this.LV.Add(, name, file)
                this.FileList.Push(file)
            }
        }
    }
    
    static OnClear() {
        this.LV.Delete()
        this.FileList := []
        this.StatusText.Text := "Список очищен."
        this.ProgBar.Value := 0
    }
    
    static UpdateProgress(percent, statusMsg) {
        this.ProgBar.Value := percent
        this.StatusText.Text := statusMsg
        Sleep(1)
    }
    
    static OnConvert() {
        if (this.FileList.Length == 0) {
            MsgBox("Добавьте хотя бы один файл .tlb в список!", "Внимание", 48)
            return
        }
        
        this.MainGui.Opt("+Disabled")
        totalFiles := this.FileList.Length
        
        name := ""
        outCode := ""
        outPath := ""
        outDir := ""
        classesMap := Map()
        
        try {
            if (this.OptSingle.Value) {
                outCode := "; Сгенерированный пакетный заголовок IntelliSense`n`n"
                outPath := A_ScriptDir "\" this.CustomNameEdit.Value
                
                for index, file in this.FileList {
                    name := ""
                    SplitPath(file, &name)
                    this.UpdateProgress(Integer((index-1)/totalFiles*100), "Обработка: " name)
                    
                    ; Прямой вызов парсера без опасных замыканий
                    classesMap := TlbParser.Scan(file)
                    
                    outCode .= "; --- Данные из файла: " name " ---`n"
                    for className, methodsMap in classesMap {
                        outCode .= TlbParser.GenerateClassCode(className, methodsMap)
                    }
                }
                
                if FileExist(outPath)
                    FileDelete(outPath)
                FileAppend(outCode, outPath, "UTF-8")
                
            } else {
                outDir := A_ScriptDir "\TLB_Export_Classes"
                if !DirExist(outDir)
                    DirCreate(outDir)
                    
                for index, file in this.FileList {
                    name := ""
                    SplitPath(file, &name)
                    this.UpdateProgress(Integer((index-1)/totalFiles*100), "Обработка: " name)
                    
                    classesMap := TlbParser.Scan(file)
                    
                    for className, methodsMap in classesMap {
                        classCode := "; Экспорт класса " className " из " name "`n`n"
                        classCode .= TlbParser.GenerateClassCode(className, methodsMap)
                        
                        classFile := outDir "\" className ".ahk"
                        if FileExist(classFile)
                            FileDelete(classFile)
                        FileAppend(classCode, classFile, "UTF-8")
                    }
                }
            }
            
            this.UpdateProgress(100, "Конвертация успешно завершена!")
            MsgBox("Все файлы успешно обработаны!", "Успех", 64)
            
        } catch Error as err {
            this.UpdateProgress(0, "Произошла ошибка.")
            MsgBox("Ошибка парсинга:`n" err.Message "`n`nВ строке: " err.Line, "Критическая ошибка", 16)
        }
        
        this.MainGui.Opt("-Disabled")
    }
}
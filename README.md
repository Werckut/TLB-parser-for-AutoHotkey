# TLB to AHK v2 Converter / Конвертер TLB в AHK v2

[English](#english) | [Русский](#русский)

---

## English

A universal, standalone binary parser that extracts COM interfaces and type libraries from `.tlb` files (Microsoft OLE/MSFT format) and automatically generates typed classes for **AutoHotkey v2**. 

It is primarily designed for developers writing automation scripts for heavy CAD systems (like **SolidWorks**), MS Office, or other software using COM interfaces. The generated files allow you to get **full VS Code IntelliSense / Auto-completion** for all available methods and classes.

### 🌟 Features
* **Completely Standalone:** Single `.exe` file. No dependencies, no local COM registration, and no installation required.
* **Bypasses System Restrictions:** Directly parses raw binary streams. Works perfectly on any Windows architecture (x86/x64) without registry tweaks.
* **Batch Processing:** Drag and drop multiple `.tlb` files simultaneously.
* **Flexible Export:** Save everything into a single file or split each interface into its own `.ahk` class file.

### 🚀 How to Use
1. Download the latest compiled executable (`.exe`) from the **Releases** section.
2. Run the application.
3. Drag and drop your target `.tlb` files into the window (or use the "Добавить файлы" button).
4. Choose your export preference (Single file or separate classes).
5. Click **"ЗАПУСТИТЬ КОНВЕРТАЦИЮ"** (Run Conversion).

### 📝 Generated Code Example
The tool extracts raw byte structures and turns them into clean AHK v2 classes with pseudo-methods used by VS Code to trigger auto-completion:

```ahk
; --- Extracted from sldworks.tlb ---

/**
 * Класс IModelDoc2
 */
class IModelDoc2 {
    /**
     * @method EditRebuild3
     */
    EditRebuild3(*) => ""

    /**
     * @method GetPathName
     */
    GetPathName(*) => ""
}
```

💻 How to Use the Output in Your Scripts
Just include the generated file at the top of your main working script. VS Code will immediately recognize the classes:

```ahk
#Requires AutoHotkey v2.0
#Include Sldworks.ahk

; VS Code will now show you autocomplete suggestions for activeDoc methods!
activeDoc := IModelDoc2()
activeDoc.EditRebuild3()
```

---

## Русский
Универсальный портативный парсер, который извлекает структуры COM-интерфейсов из файлов .tlb (формат Microsoft OLE/MSFT) и автоматически генерирует типизированные классы для AutoHotkey v2.

Утилита незаменима при написании скриптов автоматизации для тяжелых CAD-систем (таких как SolidWorks), пакетов MS Office и любых других программ, использующих COM-технологии. Сгенерированные файлы обеспечивают полноценное автодополнение методов (IntelliSense) в VS Code.

### 🌟 Возможности
Полная автономность: Программа поставляется в виде одного готового .exe файла. Не требует установки, прав администратора или регистрации библиотек в реестре Windows.

Обход системных ограничений: Читает сырой бинарный поток байт напрямую. Ей безразлична разрядность системы (x86/x64) и то, установлена ли сама целевая программа на компьютере.

Пакетная обработка: Поддержка Drag & Drop — перетаскивайте пачки .tlb файлов прямо в окно программы.

Удобный экспорт: Возможность собрать всё в один большой файл автодополнения или аккуратно разложить каждый интерфейс в отдельный файл класса.

### 🚀 Инструкция по использованию
Скачайте скомпилированный .exe файл из раздела Releases на GitHub.

Запустите приложение.

Перетащите файлы .tlb в окно программы или добавьте их через кнопку «Добавить файлы».

Выберите нужный режим экспорта (в один файл или разделение по классам).

Нажмите кнопку «ЗАПУСТИТЬ КОНВЕРТАЦИЮ».

### 📝 Пример сгенерированного кода

Парсер превращает бинарную структуру в чистые заготовки классов AHK v2 с псевдо-методами для триггера автодополнения редактора:
```ahk
; --- Извлечено из sldworks.tlb ---

/**
 * Класс IModelDoc2
 */
class IModelDoc2 {
    /**
     * @method EditRebuild3
     */
    EditRebuild3(*) => ""

    /**
     * @method GetPathName
     */
    GetPathName(*) => ""
}
```

### 💻 Как использовать результат в работе
Просто подключите сгенерированный файл через #Include в начале вашего рабочего скрипта. VS Code мгновенно подхватит структуры интерфейсов:
```ahk
#Requires AutoHotkey v2.0
#Include Sldworks.ahk

; Теперь при вводе "activeDoc." VS Code покажет список всех доступных методов!
activeDoc := IModelDoc2()
activeDoc.EditRebuild3()
```

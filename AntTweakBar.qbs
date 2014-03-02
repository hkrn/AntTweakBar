/**

 Copyright (c) 2010-2014  hkrn

 All rights reserved.

 Redistribution and use in source and binary forms, with or
 without modification, are permitted provided that the following
 conditions are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above
   copyright notice, this list of conditions and the following
   disclaimer in the documentation and/or other materials provided
   with the distribution.
 - Neither the name of the MMDAI project team nor the names of
   its contributors may be used to endorse or promote products
   derived from this software without specific prior written
   permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

*/

import qbs 1.0
import qbs.FileInfo

Product {
    id: antTweakBar
    readonly property var commonFiles: [
        "src/Mini*.h",
        "src/TwBar.h",
        "src/TwEventGL*.h",
        "src/TwFonts.h",
        "src/TwGraph.h",
        "src/TwMgr.h",
        "src/TwPrecomp.h",
        "src/resource.h"
    ].map(function(path){ return FileInfo.joinPaths(sourceDirectory, path) })
    readonly property var commonExcludeFiles: [
        "src/TwDirect3D*",
        "src/TwPrecomp.cpp*"
    ].map(function(path){ return FileInfo.joinPaths(sourceDirectory, path) })
    readonly property var commonIncludePaths: [ "include" ]
    type: "staticlibrary"
    name: "AntTweakBar"
    version: "1.16"
    excludeFiles: commonExcludeFiles
    cpp.includePaths: commonIncludePaths
    Properties {
        condition: qbs.targetOS.contains("osx")
        files: commonFiles.concat([ "src/LoadOGL*.h", "src/TwOpenGL*.h*", "src/*.mm" ].map(function(path){ return FileInfo.joinPaths(sourceDirectory, path) }))
        cpp.frameworks: [ "AppKit", "OpenGL" ]
        cpp.defines: [ "_MACOSX" ]
        cpp.minimumOsxVersion: "10.6"
    }
    Properties {
        condition: !qbs.targetOS.contains("osx")
        files: commonFiles.concat([ "src/*.cpp" ])
        excludeFiles: [ "src/TwDirect3D*" ]
    }
    Properties {
        condition: qbs.toolchain.contains("msvc")
        cpp.cxxFlags: [ "/wd4819" ]
        cpp.defines: [ "_WINDOWS", "TW_STATIC", "TW_NO_LIB_PRAGMA" ]
        cpp.windowsApiCharacterSet: undefined
    }
    Properties {
        condition: qbs.targetOS.contains("unix") && !qbs.targetOS.contains("osx")
        cpp.defines: [ "_UNIX" ]
    }
    Rule {
        condition: qbs.targetOS.contains("osx")
        inputs: [ "atb_src" ]
        Artifact {
            fileTags: [ "objcpp" ]
            fileName: "src/" + FileInfo.baseName(input.fileName) + ".mm"
        }
        prepare: {
            var args = [ "-s", input.fileName, output.fileName ]
            var command = new Command("ln", args)
            command.description = "Create symlink " + FileInfo.fileName(input.fileName) + " as " + FileInfo.fileName(output.fileName)
            return command
        }
    }
    Depends { name: "cpp" }
}

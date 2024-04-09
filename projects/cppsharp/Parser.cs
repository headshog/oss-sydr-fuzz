﻿// Copyright 2024 ISP RAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
///////////////////////////////////////////////////////////////////////////

using CppSharp.Parser;
using System;
using System.IO;
using SharpFuzz;

namespace CppSharp
{
    static class Program
    {
        public static void Main(string[] args)
        {
            Fuzzer.OutOfProcess.Run(stream =>
            {
                if (args.Length < 1)
                {
                    Console.Error.WriteLine("A path to a file for parsing is required.");
                    return;
                }

                var file = Path.GetFullPath(args[0]);
                ParseSourceFile(file);
            });
        }

        private static bool ParseSourceFile(string file)
        {
            // Lets setup the options for parsing the file.
            var parserOptions = new ParserOptions
            {
                LanguageVersion = LanguageVersion.CPP20_GNU,

                // Verbose here will make sure the parser outputs some extra debugging
                // information regarding include directories, which can be helpful when
                // tracking down parsing issues.
                Verbose = true
            };

            // This will setup the necessary system include paths and arguments for parsing.
            parserOptions.Setup(Platform.Host);

            // We create the Clang parser and parse the source code.
            var parserResult = ClangParser.ParseSourceFile(file, parserOptions);

            // If there was some kind of error parsing, then lets print some diagnostics.
            if (parserResult.Kind != ParserResultKind.Success)
            {
                if (parserResult.Kind == ParserResultKind.FileNotFound)
                    Console.Error.WriteLine($"{file} was not found.");

                for (uint i = 0; i < parserResult.DiagnosticsCount; i++)
                {
                    var diag = parserResult.GetDiagnostics(i);

                    Console.WriteLine("{0}({1},{2}): {3}: {4}",
                        diag.FileName, diag.LineNumber, diag.ColumnNumber,
                        diag.Level.ToString().ToLower(), diag.Message);
                }

                parserResult.Dispose();
                return false;
            }

            // Now we can consume the output of the parser (syntax tree).

            // First we will convert the output, bindings for the native Clang AST,
            // to CppSharp's managed AST representation.
            var astContext = ClangParser.ConvertASTContext(parserOptions.ASTContext);

            // After its converted, we can dispose of the native AST bindings.
            parserResult.Dispose();

            // Now we can finally do what we please with the syntax tree.
            foreach (var sourceUnit in astContext.TranslationUnits)
                Console.WriteLine(sourceUnit.FileName);

            return true;
        }
    }
}

// Copyright 2024 ISP RAS
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

using SharpFuzz;
using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text;
using Sprache;

public class Program
{
    static readonly Parser<char> CellSeparator = Parse.Char(',');

    static readonly Parser<char> QuotedCellDelimiter = Parse.Char('"');

    static readonly Parser<char> QuoteEscape = Parse.Char('"');

    static Parser<T> Escaped<T>(Parser<T> following)
    {
        return from escape in QuoteEscape
                from f in following
                select f;
    }

    static readonly Parser<char> QuotedCellContent =
        Parse.AnyChar.Except(QuotedCellDelimiter).Or(Escaped(QuotedCellDelimiter));

    static readonly Parser<char> LiteralCellContent =
        Parse.AnyChar.Except(CellSeparator).Except(Parse.String(Environment.NewLine));

    static readonly Parser<string> QuotedCell =
        from open in QuotedCellDelimiter
        from content in QuotedCellContent.Many().Text()
        from end in QuotedCellDelimiter
        select content;

    static readonly Parser<string> NewLine =
        Parse.String(Environment.NewLine).Text();

    static readonly Parser<string> RecordTerminator =
        Parse.Return("").End().XOr(
        NewLine.End()).Or(
        NewLine);

    static readonly Parser<string> Cell =
        QuotedCell.XOr(
        LiteralCellContent.XMany().Text());

    static readonly Parser<IEnumerable<string>> Record =
        from leading in Cell
        from rest in CellSeparator.Then(_ => Cell).Many()
        from terminator in RecordTerminator
        select Cons(leading, rest);

    static readonly Parser<IEnumerable<IEnumerable<string>>> Csv =
        Record.XMany().End();

    static IEnumerable<T> Cons<T>(T head, IEnumerable<T> rest)
    {
        yield return head;
        foreach (var item in rest)
            yield return item;
    }

    public static void Main(string[] args)
    {
        Fuzzer.OutOfProcess.Run(stream =>
        {
            try {
                string input = File.ReadAllText(args[0]);
                var r = Csv.Parse(input);
                //Console.WriteLine(r.First().ToArray()[0]);
            }
            catch (Sprache.ParseException) {}
        });
    }
}

/*
Copyright (c) 2019 Timur Gafarov

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module main;

import std.stdio;
import std.array: split;
import std.file: readText, exists, mkdir, getcwd, write;
import std.process: execute, Config;
import std.json;
import std.path: absolutePath;

struct Git
{
    string workDir;
    
    this(string dir)
    {
        workDir = dir;
    }
    
    auto cmd(string[] commands)
    {
        return execute(["git"] ~ commands, null, Config.none, size_t.max, workDir);
    }
    
    auto cmd(string command)
    {
        return cmd([command]);
    }
    
    auto clone(string url)
    {
        return cmd(["clone"] ~ url);
    }
    
    auto checkout(string branchName)
    {
        return cmd(["checkout"] ~ branchName);
    }
    
    auto pull()
    {
        return cmd("pull");
    }
}

void run()
{
    string s = readText("dependencies.json");
    JSONValue dubConfig = parseJSON(s);
    JSONValue deps = dubConfig["git"];
    
    JSONValue[string] versions;
    
    foreach(string depName, ref JSONValue _dep; deps)
    {
        string[] s = depName.split(":");
        string packageName = s[0];
        string subpackageName = "";
        if (s.length > 1)
            subpackageName = s[1];
        
        JSONValue dep = deps[packageName];
        string repoUrl = dep.array[0].str;
        string branchName = dep.array[1].str;
        string dir = ".resolve/" ~ packageName;

        if (!exists(".resolve")) 
            mkdir(".resolve");

        Git repo;
        string dirAbs = absolutePath(dir);
        
        writeln("Resolving ", depName, "@", branchName, " to ", "\"", dir, "\"...");
        
        string gitConfig = dir ~ "/.git/config";
        
        if (exists(gitConfig))
        {
            repo = Git(dirAbs);
            repo.pull();
        }
        else
        {
            repo = Git(absolutePath(".resolve"));
            repo.clone(repoUrl);
            repo = Git(dirAbs);
            repo.checkout(branchName);
        }
        
        if (subpackageName != "")
            versions[depName] = JSONValue(["path": JSONValue(dir)]);
        else
            versions[packageName] = JSONValue(["path": JSONValue(dir)]);
    }
    
    JSONValue dubSelections = JSONValue(
    [
        "fileVersion": JSONValue(1),
        "versions": JSONValue(versions)
    ]);
    
    writeln("Updating dub.selections.json...");
    write("dub.selections.json", dubSelections.toString(JSONOptions.doNotEscapeSlashes));
    
    writeln("Done. Run \"dub build\".");
}

void main()
{
    run();
}

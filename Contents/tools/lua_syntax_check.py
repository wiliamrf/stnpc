#!/usr/bin/env python3
import sys
import os
import re

def strip_comments_and_strings(s):
    # remove block comments --[[ ... ]] and long strings [[...]]
    s = re.sub(r"--\[\[[\s\S]*?\]\]", " ", s)
    s = re.sub(r"\[\[[\s\S]*?\]\]", " ", s)
    # remove line comments -- ...
    s = re.sub(r"--.*", " ", s)
    # remove single- and double-quoted strings, handling escapes
    s = re.sub(r"'(?:\\.|[^'\\])*'", " ", s)
    s = re.sub(r'\"(?:\\.|[^\\\"])*\"', " ", s)
    return s

def check_file(path):
    try:
        with open(path, 'r', encoding='utf-8') as f:
            txt = f.read()
    except Exception as e:
        return (path, False, f'Erro ao abrir arquivo: {e}')

    cleaned = strip_comments_and_strings(txt)

    def cnt(rx):
        return len(re.findall(rx, cleaned))

    results = []
    fn = cnt(r"\bfunction\b")
    ed = cnt(r"\bend\b")
    if_cnt = cnt(r"\bif\b")
    for_cnt = cnt(r"\bfor\b")
    while_cnt = cnt(r"\bwhile\b")
    do_cnt = cnt(r"\bdo\b")

    expected_ends = fn + if_cnt + for_cnt + while_cnt + do_cnt
    if expected_ends != ed:
        results.append(f"end count mismatch: expectedEnds={expected_ends} end={ed} (f={fn} if={if_cnt} for={for_cnt} while={while_cnt} do={do_cnt})")

    then_cnt = cnt(r"\bthen\b")
    if if_cnt != then_cnt:
        results.append(f"if/then mismatch: if={if_cnt} then={then_cnt}")

    rep = cnt(r"\brepeat\b")
    unt = cnt(r"\buntil\b")
    if rep != unt:
        results.append(f"repeat/until mismatch: repeat={rep} until={unt}")

    # brackets and parentheses
    par_open = cleaned.count('(')
    par_close = cleaned.count(')')
    if par_open != par_close:
        results.append(f"parentheses mismatch: (={par_open} )={par_close}")

    br_open = cleaned.count('{')
    br_close = cleaned.count('}')
    if br_open != br_close:
        results.append(f"braces mismatch: {{={br_open} }}={br_close}")

    sq_open = cleaned.count('[')
    sq_close = cleaned.count(']')
    if sq_open != sq_close:
        results.append(f"brackets mismatch: [={sq_open} ]={sq_close}")

    # check for stray quotes
    single_quotes = txt.count("'")
    double_quotes = txt.count('"')
    if single_quotes % 2 != 0:
        results.append(f"odd number of single quotes: {single_quotes}")
    if double_quotes % 2 != 0:
        results.append(f"odd number of double quotes: {double_quotes}")

    if results:
        return (path, False, "; ".join(results))
    return (path, True, "OK")

def walk_and_check(root):
    findings = []
    for dirpath, dirs, files in os.walk(root):
        for fn in files:
            if fn.lower().endswith('.lua'):
                p = os.path.join(dirpath, fn)
                findings.append(check_file(p))
    return findings

def main():
    root = sys.argv[1] if len(sys.argv) > 1 else '.'
    findings = walk_and_check(root)
    ok = True
    for path, passed, msg in findings:
        rel = os.path.relpath(path)
        if passed:
            print(f"OK: {rel}")
        else:
            ok = False
            print(f"ISSUE: {rel} -> {msg}")
    print('\nSummary:')
    total = len(findings)
    fails = sum(1 for _,p,_ in findings if not p)
    print(f"Total .lua files: {total}")
    print(f"Files with potential issues: {fails}")
    sys.exit(0 if ok else 2)

if __name__ == '__main__':
    main()

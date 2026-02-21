#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import { execFileSync } from "node:child_process";

function usage() {
  console.error("Usage: node ./xml-to-json.mjs <input.xml> [output.json]");
  process.exit(1);
}

function toNumberIfNumeric(value) {
  if (typeof value !== "string") return value;
  const trimmed = value.trim();
  if (!/^-?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?$/.test(trimmed)) {
    return value;
  }
  const num = Number(trimmed);
  return Number.isFinite(num) ? num : value;
}

function transform(xmlJsJson) {
  const source = JSON.parse(xmlJsJson);
  const elements = Array.isArray(source.elements) ? source.elements : [];
  const headers = [];

  for (const el of elements) {
    if (!el || el.type !== "element" || typeof el.name !== "string") continue;
    const opcodeElements = Array.isArray(el.elements) ? el.elements : [];
    const opcodes = [];

    for (const opcode of opcodeElements) {
      if (!opcode || opcode.type !== "element" || opcode.name !== "opcode") continue;
      const attrs = opcode.attributes || {};
      const opcodeName = attrs.name;
      if (typeof opcodeName !== "string") continue;
      const value = toNumberIfNumeric(attrs.value ?? "");
      opcodes.push({ [opcodeName]: value });
    }

    headers.push({ [el.name]: opcodes });
  }

  return { headers };
}

function formatCompactPretty(data) {
  const q = (v) => JSON.stringify(v);
  if (!data || !Array.isArray(data.headers)) {
    return `${JSON.stringify(data, null, 2)}\n`;
  }

  const lines = [];
  lines.push("{");
  lines.push('  "headers": [');

  data.headers.forEach((headerObj, headerIndex) => {
    const keys = Object.keys(headerObj || {});
    if (keys.length !== 1 || !Array.isArray(headerObj[keys[0]])) {
      const trailing = headerIndex === data.headers.length - 1 ? "" : ",";
      lines.push(`    ${JSON.stringify(headerObj)}${trailing}`);
      return;
    }

    const headerName = keys[0];
    const opcodes = headerObj[headerName];

    lines.push(`    {${q(headerName)}: [`);
    opcodes.forEach((opcodeObj, opcodeIndex) => {
      const opcodeKeys = Object.keys(opcodeObj || {});
      const trailing = opcodeIndex === opcodes.length - 1 ? "" : ",";
      if (opcodeKeys.length !== 1) {
        lines.push(`      ${JSON.stringify(opcodeObj)}${trailing}`);
        return;
      }
      const opcodeName = opcodeKeys[0];
      const opcodeValue = opcodeObj[opcodeName];
      lines.push(`      {${q(opcodeName)}: ${q(opcodeValue)}}${trailing}`);
    });
    const headerTrailing = headerIndex === data.headers.length - 1 ? "" : ",";
    lines.push(`    ]}${headerTrailing}`);
  });

  lines.push("  ]");
  lines.push("}");
  return `${lines.join("\n")}\n`;
}

function main() {
  const input = process.argv[2];
  if (!input) usage();

  const output = process.argv[3] || input.replace(/\.xml$/i, ".json");
  if (!/\.xml$/i.test(input)) {
    console.error(`Input must be an .xml file: ${input}`);
    process.exit(1);
  }

  const tempDir = fs.mkdtempSync(`${os.tmpdir()}/xml-to-json-`);
  const tempOutput = `${tempDir}/xmljs.json`;
  try {
    execFileSync(
      "xml-js",
      [input, "--spaces", "0", "--no-decl", "--out", tempOutput],
      { stdio: "pipe" }
    );
    const xmlJsOutput = fs.readFileSync(tempOutput, "utf8");
    const transformed = transform(xmlJsOutput);
    fs.writeFileSync(output, formatCompactPretty(transformed), "utf8");
  } finally {
    fs.rmSync(tempDir, { recursive: true, force: true });
  }
}

main();

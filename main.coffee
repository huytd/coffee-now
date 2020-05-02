import React, { useState, useEffect } from 'react'
import ReactDOM from 'react-dom'
import './style.scss'

compiledEditor = null
editor = null

App = () ->
  parsedCodeFromQueryParam = window.location.search.replace(/\?code=/, '') or ""
  preloaded = decodeURIComponent(parsedCodeFromQueryParam)
  [code, setCode] = useState(preloaded)
  [log, setLog] = useState(if preloaded and preloaded.length then "Copy this page URL to share" else "Press Ctrl + Enter to execute the code.")

  # Capture the content of these logs
  debugFn = (param...) ->
    setLog param.join(" ") + "\n"
  console.log = debugFn
  console.error = debugFn

  shareCode = () ->
    window.location.search = "code=" + encodeURIComponent(code)

  clearLog = () ->
    setLog ""

  compileCode = (script) ->
    try
      compiled = CoffeeScript.compile (script or code)
      compiledEditor?.setValue(compiled)
    catch error
      setLog error.toString()

  executeCode = (script) ->
    clearLog()
    try
      compileCode(script or code)
      CoffeeScript.run (script or code)
    catch error
      setLog error.toString()

  useEffect () ->
    editor = CodeMirror.fromTextArea(document.querySelector("#editor"), {
      mode: 'text/coffeescript',
      lineNumbers: true,
      extraKeys: {
        'Ctrl-Enter': () ->
          executeCode editor.getValue()
        'Cmd-Enter': () ->
          executeCode editor.getValue()
        'Ctrl-S': () ->
          shareCode()
        'Cmd-S': () ->
          shareCode()
      }
    })

    editor.on "change", () ->
      value = editor.getValue()
      setCode value

    compiledEditor = CodeMirror.fromTextArea(document.querySelector("#compiled-editor"), {
      mode: 'text/coffeescript',
      lineNumbers: true,
      readOnly: "nocursor"
    })

    () -> {}
  , []

  <div className={"main"}>
    <div className={"toolbar"}>
      <button onClick={shareCode} className={"btn secondary"}>share</button>
      <button onClick={() -> clearLog()} className={"btn secondary"}>clear log</button>
      <button onClick={() -> compileCode()} className={"btn"}>compile</button>
      <button onClick={() -> executeCode()} className={"btn"}>execute</button>
    </div>
    <div className={"ide"}>
      <div className={"editor-zone"}>
        <textarea id="editor" className={"editor"} defaultValue={preloaded}></textarea>
        <textarea id="compiled-editor" className={"compiled-code"}></textarea>
      </div>
      <pre id={"debugger"} className={"debugger"}>{log}</pre>
    </div>
  </div>

ReactDOM.render <App/>, document.querySelector("#root")
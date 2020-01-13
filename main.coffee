import React, { useState, useEffect } from 'react'
import ReactDOM from 'react-dom'
import './style.scss'

BOILERPLATE = """
stdout = document.querySelector "#debugger"

__log_clear = () ->
  stdout.innerHTML = ""

debug = (param...) ->
  stdout.innerHTML += param.join(" ") + "<br/>"

console.log = debug
console.error = debug

__log_clear()
"""

App = () ->
  [code, setCode] = useState("")
  [log, setLog] = useState("")

  clearLog = () ->
    setLog ""

  executeCode = (script) ->
    try
      CoffeeScript.run BOILERPLATE + "\n" + (script or code)
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
      }
    })

    editor.on "change", () ->
      value = editor.getValue()
      setCode value
  , []

  <div className={"main"}>
    <div className={"toolbar"}>
      <button onClick={executeCode} className={"btn"}>execute</button>
      <button onClick={clearLog} className={"btn"}>clear log</button>
    </div>
    <div className={"ide"}>
      <textarea id="editor" className={"editor"}></textarea>
      <pre id={"debugger"} className={"debugger"}>{log}</pre>
    </div>
  </div>

ReactDOM.render <App/>, document.querySelector("#root")
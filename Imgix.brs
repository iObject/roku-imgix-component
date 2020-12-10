sub init()
  topRef = m.top
  m.poster = topRef.findNode("poster")
  m.debounce = topRef.findNode("debounce")
  m.interp = topRef.findNode("interp")
  
  topRef.observeField("uri", "onTopUriChange")
  m.debounce.observeField("state", "onDebounceStateChange")
  m.poster.observeField("loadStatus", "onLoadStatusChange")

  m.fetchColorPalleteTask = Invalid

  m.copyOneForOneParamStrings = [
    "auto"
    "blend"
    "blend-align"
    "blend-color"
    "blend-crop"
    "blend-fit"
    "blend-mode"
    "blend-size"
    "border"
    "fit"
    "fm"
  ]

  m.copyNonZeroFloatParams = [
    "bri"
    "width"
    "height"
  ]

  m.copyNonNegativeFloatParams = [
    "blend-alpha"
    "border-left"
    "border-right"
    "border-top"
    "border-bottom"
    "blend-h"
    "blend-pad"
    "blend-w"
    "blend-x"
    "blend-y"
  ]
end sub

sub onTopUriChange(event as Object)
  m.fetchColorPalleteTask = Invalid
  m.colorPallete = {}
  m.interp.reverse = true
  m.debounce.control = "start"
end sub

sub onDebounceStateChange(event as Object)
  state = event.getData()

  if m.interp.reverse = false return

  if state = "stopped" then
    uri = generateImigxUri(m.top.uri)
    if m.top.fetchColorPallete then
      m.fetchColorPalleteTask = createObject("roSGNode", "ImgixFetchJSON")
      m.fetchColorPalleteTask.observeField("response", "onColorPalleteFetched")
      m.fetchColorPalleteTask.url = applyParametersToUri(uri, {
        "palette": "json"
      })
    end if
    m.poster.uri = uri
  end if
end sub

function generateImigxUri(sourceUri = "" as String) as String
  topRef = m.top
  width = 0
  height = 0

  parameters = {}

  for each key in m.copyOneForOneParamStrings
    value = m.top[key]
    if NOT value = "" then
      parameters[key] = value
    end if
  end for

  for each key in m.copyNonZeroFloatParams
    value = m.top[key]
    if NOT value = 0 then
      parameters[key] = value.toStr()
    end if
  end for

  for each key in m.copyNonNegativeFloatParams
    value = m.top[key]
    if value >= 0 then
      parameters[key] = value.toStr()
    end if
  end for


  borderRadius = topRef["border-radius"]
  if NOT borderRadius.count() = 0 then
    while borderRadius.count() < 4
      borderRadius.push(borderRadius[borderRadius.count() -1])
    end while

    index = 0
    for each value in borderRadius
      borderRadius[index] = value.toStr()
      index ++
    end for
    parameters.append({
      "border-radius": borderRadius.join(",")
    })
  end if

  ' Validations
  blendSize = parameters["blend-size"]
  if NOT blendSize = Invalid AND NOT blendSize = "inherit" then parameters.delete("blend-size")

  return applyParametersToUri(sourceUri, parameters)
end function

sub onLoadStatusChange(event as Object)
  status = event.getData()
  if status = "failed" OR status = "ready" then
    m.interp.reverse = false
    m.debounce.control = "start"
  end if
end sub


sub onColorPalleteFetched(event as Object)
  m.top.colorPallete = event.getData()
  m.fetchColorPalleteTask.control = "stop"
  m.fetchColorPalleteTask = Invalid
end sub



function applyParametersToUri(uri = "" as String, queryParameters = {} as Object) as String
	if NOT uri = "" then
		first = (0 = Instr(0, uri, "?"))

		for each key in queryParameters
			value = queryParameters[key]

			if NOT value = "" then
				if first then
					uri += "?"
					first = false
				else
					uri += "&"
				end if

				uri += (key.encodeUriComponent() + "=" + value.encodeUriComponent())
			end if
		end for
	end if

	return uri
end function
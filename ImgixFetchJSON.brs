sub init()
  topRef = m.top
  topRef.observeField("url", "onUrlChange")
  topRef.functionName = "getContent"
end sub


sub onUrlChange(event as Object)
  m.top.control = "RUN"
end sub


sub getContent()
  topRef = m.top
  transfer = CreateObject("roUrlTransfer")
  transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
  transfer.AddHeader("X-Roku-Reserved-Dev-Id", "")
  transfer.InitClientCertificates()
  transfer.setUrl(topRef.url)
  
  response = transfer.GetToString()
  m.top.response = parseJson(response)
end sub
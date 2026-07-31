<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="NetFramework4App.Default" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>.NET Framework 4 Sample</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h1>.NET Framework 4 IIS Sample App</h1>
            <p>Application deployed successfully.</p>
            <p>Host: <%= Server.MachineName %></p>
            <p>Timestamp: <%= DateTime.UtcNow.ToString("u") %></p>
            <p>Version: <%= this.AppVersion %></p>
        </div>
    </form>
</body>
</html>

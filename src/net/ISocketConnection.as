package net
{
    public interface ISocketConnection
    {
        function init(messenger:Messenger, peer:Peer):void;
        function disconnect():void;
        function shutdown():void;
    }
}
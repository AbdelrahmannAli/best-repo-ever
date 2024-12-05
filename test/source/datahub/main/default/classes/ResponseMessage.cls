@JsonAccess(serializable='always' deserializable='always')
global  with sharing class ResponseMessage {

    global  enum MessageType {
        ERROR,
        WARNING,
        INFO,
        SUCCESS
    }

    global  boolean isSuccess;
    global  Object data;
    global  String message;
    global  MessageType type;

    global  ResponseMessage(boolean isSuccess, Object data, String message) {
        this.isSuccess = isSuccess;
        this.data = data;
        this.message = message;
    }

    global  ResponseMessage(Object data, String message, MessageType type) {
        this.data = data;
        this.message = message;
        this.type = type;
        this.isSuccess = type == Syntilio.ResponseMessage.MessageType.SUCCESS;
    }
    
    global  String serialize() {
        Map<String, Object> mappedAttr = new Map<String, Object>();
        mappedAttr.put('isSuccess', this.isSuccess);
        mappedAttr.put('data', this.data);
        mappedAttr.put('message', this.message);
        mappedAttr.put('type', this.type);
        return JSON.serialize(mappedAttr);
    }
    
    global  static Syntilio.ResponseMessage.MessageType getSyntilioMessageType(String messageType) {
        switch on messageType {
            when 'ERROR' {
                return Syntilio.ResponseMessage.MessageType.ERROR;
            }
            when 'SUCCESS' {
                return Syntilio.ResponseMessage.MessageType.SUCCESS;
            }
            when 'INFO' {
                return Syntilio.ResponseMessage.MessageType.INFO;
            }
            when 'WARNING' {
                return Syntilio.ResponseMessage.MessageType.WARNING;
            }
            when else {
                return null;
            }
        }
    }
    
    global  static ResponseMessage deserialize(String msg) {
        Map<String, Object> mappedAttr = (Map<String, Object>) JSON.deserializeUntyped(msg);
        ResponseMessage responseMessage = new ResponseMessage(
            (Object) mappedAttr.get('data'),
            (String) mappedAttr.get('message'),
            (Syntilio.ResponseMessage.MessageType) getSyntilioMessageType((String) mappedAttr.get('type'))
        );
        return responseMessage;
    }
}
//
//  UVEC.swift
//
//  Created by Jan Anstipp on 18.10.20.
//

extension JSONEncoderIO{
    
    struct UEC: UnkeyedEncodingContainer {
        
        var codingPath: [CodingKey]

        var data: EncoderData
        var count: Int = 0
        let isDebug = false
        
        init(_ data: inout EncoderData,_ codingPath: [CodingKey]) {
            self.data = data
            self.codingPath = codingPath
            try! self.data.addArray(codingPath.path())
        }
        
        mutating private func addValue(_ value: Any) throws {
            count += 1
            try data.addArrayItem(codingPath.path(), value)
        }
        
        mutating func encodeNil() throws {
            try addValue(JSONNull())
        }
        
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            let path = codingPath.appending(key: JSONKey(intValue: count))
            try data.addLink(codingPath.path(),String(count))
            count += 1
            try value.encode(to: JSONEncoderIO(path, &data))
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            try! data.addLink(codingPath.path(),String(count))
            return KeyedEncodingContainer(JSONEncoderIO.KEC(&data, codingPath.appending(key: JSONKey(intValue: count))))
            
        }
        
        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            try! data.addLink(codingPath.path(),String(count))
            return UEC(&data, codingPath.appending(key: JSONKey(intValue: count)))
        }
        
        mutating func superEncoder() -> Encoder {
            try! data.addLink(codingPath.path(),String(count))
            return JSONEncoderIO(codingPath.appending(key: JSONKey(intValue: count)), &data)
        }
        
    }
}



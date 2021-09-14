pragma solidity >= 0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;


contract Eventos{
    
    event evento1(string _nombre);
    event evento2(string _nombre, uint edad);
    event evento3(string,uint,address,bytes32);
    event abortarMision();
    
    function emitirEvento1(string memory _nombre) public{
        emit evento1(_nombre);


    }

    
    function emitirEvento2(string memory _nombre, uint edad) public{
        emit evento2(_nombre,edad);
    }
    
    function emitirEvento3(string memory _nombre, uint _edad ) public{
        
        bytes32 hash = keccak256(abi.encodePacked(_nombre,_edad, msg.sender));
        emit evento3(_nombre,_edad,msg.sender,hash);
        
    }
    
    
    function abortarMisionFunction() public{
        emit abortarMision();
    }
}

pragma solidity >= 0.4.4 < 0.7.0;

contract Banco{
    
    //Definimos tipo dato comlplejo
    struct cliente{
        string nombre;
        address billetera;
        uint dinero;
    }
    
    //Mapping para relacionar nombre con el tipo de dato de Cliente
    mapping(string => cliente) public mapaCliente ;
    
    
    
    //Funcion que permite dar de alta un nuevo cliente
    function nuevoCliente(string memory _nombre) internal {
        
        mapaCliente[_nombre] = cliente(_nombre,msg.sender,0);
        
    }
    
}


contract Banco2{
    
}


contract Banco3{
    
}
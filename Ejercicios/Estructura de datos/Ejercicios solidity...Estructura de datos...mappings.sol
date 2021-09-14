pragma solidity >=0.4.0 < 0.7.0;
pragma experimental ABIEncoderV2;

contract Mappings{
    
    //Mapping para elegir un número
    mapping(address => uint) public elegirNumero;   
    
    function eligeNumero(uint _numero) public {
    
        elegirNumero[msg.sender] = _numero;
        
    }
    
    function consultarNumero() public view returns (uint){
        return(elegirNumero[msg.sender]);
    }
    
    
    //Declaramos un mapping que relaciona el nombre de una persona con su cantidad de dinero
    
    mapping(string => uint) public personadinero;
    
    function aniadirPersonaDinero(string memory _nombre, uint dinero) public {

     personadinero[_nombre] = dinero;

    }
    
    function consultardinero(string memory _nombre) public view returns(uint){
        
        return personadinero[_nombre];
    }
    
    
    // Mapping con structs
    
    struct Persona {
        string nombre;
        uint edad;
    }
    
    mapping(uint => Persona) personas;
    
    function aniadirPersona(uint _numeroDni, string memory _nombre, uint edad) public{
        personas[_numeroDni] = Persona(_nombre,edad);
    }
    
    function consultarPersona(uint _dni) public view returns (Persona memory) {
        return personas[_dni];
    }
    
    
    
}
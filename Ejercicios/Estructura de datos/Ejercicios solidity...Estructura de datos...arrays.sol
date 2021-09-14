pragma solidity >= 0.4.0 < 0.7.0;

contract Arrays{
    
    
    //Array longitud fija
    uint[5]  arrayentero = [5,2,3];
    string[5]  arraystrings;
    uint32[5]  arraybits;
    
    
    //Array dinámico
    uint[] public arraydinamicoenteros;
    
    struct Persona{
        string nombre;
        uint edad;
    }
    
    Persona[]  public array_personas;
    
    
    function modificar_array(string memory _nombre,uint _edad) public{
      //arraydinamicoenteros.push(_numero);
      //array_personas.push(Persona(_nombre,_edad));
      //arrayentero[1] = 56;
        
    }
    
    
    uint public test = arrayentero[2];
}
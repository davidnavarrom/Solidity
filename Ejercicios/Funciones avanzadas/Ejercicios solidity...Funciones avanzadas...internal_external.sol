pragma solidity >=0.4.4 < 0.7.0;

contract Comida{
    
    struct Plato{
        string nombre;
        string ingredientes;
        uint tiempo_coccion;
    }
    
    //Declarar un array dinamico de platos
    Plato[] platos;
    //Relacionamos con mapping el nombre del plato con sus ingredientes
    mapping(string => string) ingredientes;
    
    //Función que nos permite dar de alta un nuevo plato
    function nuevoPlato(string memory _nombre, string memory _ingredientes, uint tiempo_coccion) internal{
        platos.push(Plato(_nombre,_ingredientes,tiempo_coccion));
        ingredientes[_nombre] = _ingredientes; 
    }
    
    function verIngredientes(string memory _nombre) internal view returns (string memory) {
        return ingredientes[_nombre];
    }
}


contract Sandwich is Comida{
    
    function sandwich(string memory _ingredientes, uint _tiempo_coccion) external{
        nuevoPlato("Sandwich", _ingredientes, _tiempo_coccion);
    }
    
    function verIngredientesComida() external view returns (string memory){
        
        return verIngredientes("Sandwich");
    }
    
}
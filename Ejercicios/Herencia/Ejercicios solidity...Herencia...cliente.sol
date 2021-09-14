pragma solidity >= 0.4.4 < 0.7.0;
//import "./banco.sol";
import {Banco} from "./banco.sol";

contract Cliente is Banco{
    
    //Damos de alta un cliente en mapaCliente;
    function altaCliente(string memory _nombre) public{
        nuevoCliente(_nombre);
    }
    
    //Modificamos el valor de dinero de la estructura cliente
    function ingresarDinero(string memory _nombre, uint cantidad) public{
        cliente storage cliente = mapaCliente[_nombre];
        cliente.dinero = cliente.dinero + cantidad;
        
       // cliente memory cliente = mapaCliente[_nombre];
       // cliente.dinero = cliente.dinero + cantidad;
       // mapaCliente[_nombre] = cliente;

       // mapaCliente[_nombre].dinero = mapaCliente[_nombre].dinero + cantidad;
    }
    
    function retirarDinero(string memory _nombre, uint cantidad) public returns (bool){
        
        bool operacionRealizada = false;
        
        if(int(mapaCliente[_nombre].dinero)-int(cantidad) >= 0){
            mapaCliente[_nombre].dinero = mapaCliente[_nombre].dinero - cantidad;
            operacionRealizada = true;
        }
        
        return operacionRealizada;
        
    }
    
    
    function consultarDinero(string memory _nombre) public view returns(uint){
        return mapaCliente[_nombre].dinero;
    }
}
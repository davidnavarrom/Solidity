pragma solidity >= 0.4.4 < 0.7.0;

contract Estructuras{
    
    struct Cliente {
        string name;
        uint id;
        string dni;
        string email;
        uint phone_number;
        uint credit_number;
        uint secret_number;
    }
    
    Cliente cliente = Cliente("David",1,"34343434Q","david@david.com",12345678,5353535,4444);
    
    struct Producto{
        string nombre;
        uint precio;
    }
    
    Producto manzana = Producto("Manzana",100);
    
    struct ONG{
        address ong;
        string nombre;
    }
    
    ONG caritas = ONG(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,"Caritas");
    
    struct Causa{
        uint id;
        string nombre;
        uint precio_objetivo;
    }
    
    Causa causa = Causa(1,"medicamentos",1000);

}
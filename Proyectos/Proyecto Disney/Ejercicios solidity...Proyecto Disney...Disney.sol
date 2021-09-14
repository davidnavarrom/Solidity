// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney{
    
    // ---------------------- DECLARACIONES INICIALES -----------------------
    
    // Instancia del token
    ERC20Basic private token;
    // Dirección de disney
    address payable public owner;
    
    // constructor
    constructor() public{
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }
    
    // Estructura de datos para almacenar clientes de disney
    struct Cliente{
        uint tokens_comprados;
        string [] atracciones_disfrutadas;
    }
    
    // Mapping para el registro de clientes
    mapping(address => Cliente) public clientes;
    
    // ---------------------- GESTIÓN DE TOKENS -----------------------
    
    // Funcion para establecer el precio de un TOKEN
    function precioTokens(uint _numTokens) internal pure returns (uint){
        // Conversión token a ethers: 1 token -> 1 ether
        return _numTokens * (1 ether);
    }
    
    // Funcion para comprar tokens disney y disfrutar de las atracciones
    function compraTokens(uint _numTokens) public payable{
        // Establecer el precio de los tokens
        uint coste = precioTokens(_numTokens);
        // Evaluamos el dinero que el cliente paga con los tokens
        require(msg.value >= coste, "Compra menos tokens o paga mas ethers");
        // Diferencia de lo que el cliente paga
        uint returnValue = msg.value - coste;
        // Disney retorna la cantidad de ethers al cliente
        msg.sender.transfer(returnValue);
        // Obtención del numero de tokens disponibles
        uint balance = balanceOf();
        require(_numTokens <= balance, "compra un numero menor de tokens");
        // Se transfiere el numero de tokene al cliente
        token.transfer(msg.sender,_numTokens);
        // Se registra el numero de tokenn comprados por el cliente
        clientes[msg.sender].tokens_comprados = _numTokens;
    }
    
    // Balance del token del contrato disney
    function balanceOf() public view returns(uint){
        return token.balanceOf(address(this));
    }
    
    // Visualizamos numero de tokens restantes de un cliente
    function misTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }
    
    // funcion para generar mas tokens
    function generarToken(uint _numTokens) public Unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    
    // ---------------------- MODIFIERS -----------------------
     
    // Modificador para controlar que las funciones sean realizadas por el owner
     modifier Unicamente(address direccion){
         require(direccion == owner, "No eres administrador del contrato");
         _;
     }
     
    // ----------------------GESTION DE DISNEY -----------------------
     
    // Eventos
     event disfruta_atraccion(string);
     event nueva_atraccion(string,uint);
     event baja_atraccion(string);
     
     event disfruta_comida(string);
     event nueva_comida(string,uint);
     event baja_comida(string);
     
    // Estructura de las atracciones
     struct Atraccion {
         string nombre;
         uint precio_atraccion;
         bool estado;
     }
     
    // Estructura de la comida
     struct Comida {
         string nombre;
         uint precio_comida;
         bool estado;
     }
     
     // Mapping para relacionar nombre de atraccion con estructura de datos de la atraccion
     mapping(string => Atraccion) public mappingAtracciones;
     
     // Mapping para relacionar nombre de comida con estructura de datos de la atraccion
     mapping(string => Comida) public mappingComidas;
     
     // Array para almacenar el nombre de las atracciones
     string[] atracciones;
     
     // Array para almacenar el nombre de las comidas
     string[] comidas;
     
     // Mapping para relacionar cliente con su historial de atracciones en DISNEY
     mapping(address => string[]) historialAtracciones;
     
     // Mapping para relacionar cliente con su historial de comida en DISNEY
     mapping(address => string[]) historialComida;
     
     
     // Starwars -> 2 tokens
     // ToyStory -> 5 tokens
     // PiratasCaribe -> 8 tokens
     // Dar de alta una nueva atracción
     function nuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender){
         // Creamos atraccion
         require(existeAtraccion(_nombreAtraccion) == false, "La atraccion ya existe");
         mappingAtracciones[_nombreAtraccion] = Atraccion(_nombreAtraccion,_precio, true);
         atracciones.push(_nombreAtraccion);
         // Emisor evento nueva atraccion
         emit nueva_atraccion(_nombreAtraccion,_precio);
     }
    
     // Dar de alta una nueva comida
    function nuevaComida(string memory _nombreComida, uint _precio) public Unicamente(msg.sender){
         // Creamos atraccion
         require(existeComida(_nombreComida) == false, "La comida ya existe");
         mappingComidas[_nombreComida] = Comida(_nombreComida,_precio, true);
         comidas.push(_nombreComida);
         // Emisor evento nueva atraccion
         emit nueva_comida(_nombreComida,_precio);
     }
     
     // Dar de baja una atraccion existente
     function bajaAtraccion(string memory _nombreAtraccion) public Unicamente(msg.sender){
         require(existeAtraccion(_nombreAtraccion) == true, "No existe la atraccion");
         mappingAtracciones[_nombreAtraccion].estado = false;
         emit baja_atraccion(_nombreAtraccion);
     }
     
     // Dar de baja una comida existente
     function bajaComida(string memory _nombreComida) public Unicamente(msg.sender){
         require(existeComida(_nombreComida) == true, "No existe la comida");
         mappingComidas[_nombreComida].estado = false;
         emit baja_comida(_nombreComida);
     }
     
     // Comprobar si existe la atraccion que se va a crear o borrar
     function existeAtraccion(string memory _nombreAtraccion) internal view returns(bool){
        bool exists = false;
        if(keccak256(abi.encodePacked(mappingAtracciones[_nombreAtraccion].nombre)) != keccak256(abi.encodePacked(""))){
            exists = true;
        }
        return exists;
     }
     
      // Comprobar si existe una comida que se va a crear o borrar
     function existeComida(string memory _nombreComida) internal view returns(bool){
        bool exists = false;
        if(keccak256(abi.encodePacked(mappingComidas[_nombreComida].nombre)) != keccak256(abi.encodePacked(""))){
            exists = true;
        }
        return exists;
     }
     
    // Visualizar las atracciones de DISNEY
     function atraccionesDisponibles() public view returns(string[] memory){
         return atracciones;
     }
     
    // Visualizar las comidas de DISNEY
     function comidasDisponibles() public view returns(string[] memory){
         return comidas;
     }
     
    // Funcion para subirse a atraccion de disney y pagar tokens_comprados
    function subirAtraccion(string memory _nombreAtraccion) public payable{
        // Comprobamos que existe la atraccion
        require(existeAtraccion(_nombreAtraccion) == true, "No existe la atraccion");
        // Comprobamos que la atraccion esta disponibles
        require(mappingAtracciones[_nombreAtraccion].estado == true, "Atraccion no disponible en estos momentos");
        // Obtenemos el precio de la atraccion
        uint precio_token_atraccion = mappingAtracciones[_nombreAtraccion].precio_atraccion;
        // Comprobamos que el usuario puede pagar la atraccion
        require(precio_token_atraccion <= misTokens(), "Mo tienes suficiente saldo");
        // Realizamos la transferencia de tokens al contrato
        /* El cliente paga la atraccion en tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de transferencia_disney
        debido a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian para realizar la transaccion 
        eran equivocadas. Ya que el msg.sender que recibia el metodo transfer o transferfrom era la direccion del contrato.
        */
        token.transferencia_disney(msg.sender,address(this),precio_token_atraccion);
        // Almacenamos el historial del cliente
        historialAtracciones[msg.sender].push(_nombreAtraccion);
        // Notificamos que el cliente ha disfrutado de una atraccion
        emit disfruta_atraccion(_nombreAtraccion);
    }
    
    // Funcion para comprar comida de disney y pagar con tokens_comprados
    function comprarComida(string memory _nombreComida) public payable{
        // Comprobamos que existe la comida
        require(existeComida(_nombreComida) == true, "No existe la comida");
        // Comprobamos que la comida esta disponibles
        require(mappingComidas[_nombreComida].estado == true, "Comida no disponible en estos momentos");
        // Obtenemos el precio de la atraccion
        uint precio_token_comida = mappingComidas[_nombreComida].precio_comida;
        // Comprobamos que el usuario puede pagar la comida
        require(precio_token_comida <= misTokens(), "Mo tienes suficiente saldo");
        // Realizamos la transferencia de tokens al contrato
        /* El cliente paga la comida en tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de transferencia_disney
        debido a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian para realizar la transaccion 
        eran equivocadas. Ya que el msg.sender que recibia el metodo transfer o transferfrom era la direccion del contrato.
        */
        token.transferencia_disney(msg.sender,address(this),precio_token_comida);
        // Almacenamos el historial del cliente
        historialComida[msg.sender].push(_nombreComida);
        // Notificamos que el cliente ha disfrutado de una atraccion
        emit disfruta_comida(_nombreComida);
    }
    
    // Visualizar el historial de atracciones de un cliente
    function historialClienteAtracciones() public view returns (string[] memory){
        return historialAtracciones[msg.sender];
    }
    
       // Visualizar el historial de atracciones de un cliente
    function historialClienteComida() public view returns (string[] memory){
        return historialComida[msg.sender];
    }
    
    // Funcion para que un cliente Disney pueda devolver tokens
    function devolverTokens(uint _numTokens) public payable{
        require(_numTokens > 0, "Necesitas devolver una cantidad positiva");
        require(misTokens() >= _numTokens, "No tienes suficientes tokens");
        token.transferencia_disney(msg.sender,address(this),_numTokens);
        msg.sender.transfer(precioTokens(_numTokens));
    }
}
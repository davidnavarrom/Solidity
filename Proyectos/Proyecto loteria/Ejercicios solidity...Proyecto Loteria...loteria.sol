    // SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Loteria{
    
    // Instancia del contrato token
    ERC20Basic private token;
    
    // Direcciones
    address public owner;
    address public contrato;
    
    // Numero de tokens a crear
    uint public tokens_creados = 10000;
    
    // Eventos
    
    event compraDetokens(uint cantidad, address direccion);
    
    constructor() public{
        token = new ERC20Basic(tokens_creados);
        owner = msg.sender;
        contrato  = address(this);
    }
    
    // ------------------ TOKEN ------------------
    
    // Establecemos el precio del token en ethers
    function precioTokens(uint _numTokens) internal pure returns(uint){
        return _numTokens*(1 ether);
    }
    
    // Generar más tokens por la lotería
    function generarTokens(uint _numTokens) public Unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    
    // Modificador para hacer funciones que solo sean accesibles por el owner del contrato
    modifier Unicamente(address _direccion){
        require(_direccion == owner, "No tienes permisos para ejecutar esta funcion");
        _;
    }
    
    // Comprar tokens para comprar boletos para la loteria
    function comprarTokens(uint _cantidad) public payable {
        // Calcular el coste de los tokens
        uint coste = precioTokens(_cantidad);
        // Se requiere que el valor de etheres pagados sea equivalente al coste
        require(msg.value >= coste, "Compra menos tokens o paga con mas ethers");
        // Diferencia a pagar si ha enviado mas ethers de los que quiere comprar
        uint returnValue = msg.value - coste;
        // Se le devuelve la diferencia
        msg.sender.transfer(returnValue);
        // Obtenemos balance de los tokens a comprar con los tokens disponibles
        uint balance = tokensDisponibles();
        // Filtro para evaluar los tokens a comprar con los tokens disponibles
        require(_cantidad <= balance, "Compra un numero de tokens adecuado");
        // Transferimos el token al comprados
        token.transfer(msg.sender, _cantidad);
        emit compraDetokens(_cantidad,msg.sender);
    }
    
    // Balance de tokens en el contrato de loteria
    function tokensDisponibles() public view returns(uint){
        return token.balanceOf(address(this));
    }
    
    // Obtener el balance de tokens acumulados en el bote (que se envian a la cuenta owner). 
    function bote() public view returns(uint){
        return token.balanceOf(owner);
    }
    
    // Obtener el numero de tokens comprados de una persona
    function misTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }
    
    // ------------------ LOTERIA ------------------

    // Precio del boleto
    uint public precioBoleto = 5;
    // Relacion de la persona que compra los boletos y los numeros de los boletos
    mapping(address => uint []) idPersona_Boletos;
    // Relacion necesaria para identificar al ganador
    mapping(uint => address) ADN_boleto;
    // Numero aleatorio
    uint randNonce = 0;
    // Boletos generados
    uint[] boletosComprados;
    
    //Eventos
    event boleto_comprado(uint, address); // Cuando se compra un boleto
    event boleto_ganador(uint, address); // Evento del ganaodor
    event tokens_devueltos(uint, address);
    
    // Funcion para comprar boletos de LOTERIA
    function compraBoleto(uint cantidad) public {
        // Precio total de los boletos a comprar
        uint precio_total = cantidad * precioBoleto;
        // Filtro de los tokens a pagar
        require (precio_total <= misTokens(), "No tienes suficientes tokens");
        // Transferencia de tokens al owner -> bote/premio
         /* El cliente paga la loteria en tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de transferencia_loteria
        debido a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian para realizar la transaccion 
        eran equivocadas. Ya que el msg.sender que recibia el metodo transfer o transferfrom era la direccion del contrato.
        */
        token.transferencia_loteria(msg.sender, owner, precio_total);
        
        /*
        Toma la marca de tiempo now, el msg.sender y un nonce (numero que solo se utiliza una vez, para que no ejecutremos dos veces la misma funcion de hash con los mismos parametros de entrada) 
        en incremento. Luego se utiliza keccack256 para convertir estas entradas a un hash aleatorio,
        convertir ese hash a uint y luego utilizamos %10000 para tomar los ultimos 4 digitos.
        Dando un valor aleatorio entre 0 - 9999.
        */
        for(uint i = 0; i < cantidad; i++){
            uint random = uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % 10000;
            randNonce++;
            // Almacenamos los datos de los boletos
            idPersona_Boletos[msg.sender].push(random);
            // Numero de boleto comprado
            boletosComprados.push(random);
            // Asignacion del adn del boleto para tener un ganador
            ADN_boleto[random] = msg.sender;
            emit boleto_comprado(random,msg.sender);
        }
    }
    
    function misBoletos() public view returns (uint [] memory){
        return idPersona_Boletos[msg.sender];
    }
    
    // Funcion para generar un ganador
    function generaGanador() public payable Unicamente(msg.sender){
        require(boletosComprados.length > 0, "No hay boletos");
        uint longitud = boletosComprados.length;
        // Aleatoriamente elijo un numero entre 0 - longitud
        // 1.- Eleccion de una posiiucion aleatoria del array
        uint posicion_array = uint (uint(keccak256(abi.encodePacked(now))) % longitud);
        // 2.- Seleccion del numero aleatorio mediante la posicion del array aleatorio
        uint eleccion = boletosComprados[posicion_array];
        // Recuperamos direccion del ganador
        address direccion_ganador = ADN_boleto[eleccion];
        // Emitimos evento del ganador
        emit boleto_ganador(eleccion,direccion_ganador);
        // Transferimos el bote al ganador
        token.transferencia_loteria(msg.sender,direccion_ganador, bote());
    }
    
    // Devolucion de los tokens al comprador
    function devolverTokens(uint _numTokens) public payable {
        // El valor debe ser mayor que 0
        require(_numTokens > 0, "necesitas devolver un numero positivo de tokens");
        // El usuario debe disponer los tokens que desea devolver
        require(misTokens() >= _numTokens, "No tienes tantos tokens");
        // El cliente devuelve los tokens
        // 1.- El cliente devuelve los tokens
        token.transferencia_loteria(msg.sender,address(this), _numTokens);
        // 2.- La loteria paga los tokens devueltos
        msg.sender.transfer(precioTokens(_numTokens));
        emit tokens_devueltos(_numTokens,msg.sender);
    }
}
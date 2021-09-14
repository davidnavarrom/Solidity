//SPDX-License-Identifier: MIT

pragma solidity >= 0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./OperacionesBasicas.sol";
import "./ERC20.sol";

// Contrato para la compañia de seguros

/*
ESTRUCTURACIÓN DE UN CONTRATO DE ACUERDO A LAS MEJORES PRÁCTICAS DE PROGRAMACIÓN SOLIDITY:
    1.- PRAGMA SOLIDITY
    2.- IMPORTS
    3.- INTERFACES
    4.- LIBRERIAS
    5.- CONTRACT
    6.- USINGS
    7.- VARIABLES
        7.1- constantes
        7.2- locales
    8.- EVENTOS
    9.- MODIFICADORES
    10.-ESTRUCTURAS
    11.-CONSTRUCTOR
    12.-FUNCIONES
        12.1-external
        12.2-public
        12.3-internal
        12.4-private
*/
contract InsuranceFactory is OperacionesBasicas{
    
    // ----------------------------- VARIABLES -----------------------------
    
    ERC20Basic private token;
    
    address insurance; // Dirección del propio contrato
    address payable public owner; // Dirección del que despliega el contrato (aseguradora)

    // Mapeo para clientes, servicios y laboratorios
    mapping(address => Cliente) public mappingClientes;
    mapping(string => ServicioAseguradora) public mappingServicios;
    mapping(address => Laboratorio) public mappingLaboratorios;

    // Arrays para clientes, servicios y laboratorios
    address[] direccionesClientes;
    string[] private nombreServicios;
    address[] direccionesLaboratorios;

    // ----------------------------- EVENTOS -----------------------------
    event EventoTokenComprado(uint256);
    event EventoServicioProporcionado(address, string,uint); // asegurado, nombre del servicio, precio
    event EventoLaboratorioCreado(address, address);// direccion del laboratio, direccion del contrato
    event EventoClienteCreado(address, address); // direccion del asegurado y del contrato del mismo
    event EventoBajaCliente(address); 
    event EventoServicioCreado(string, uint); // nombre y precio del servicio
    event EventoBajaServicio(string); 

    // ----------------------------- MODIFICADORES -----------------------------
    
    modifier unicamenteCliente(address _direccionCliente){
        checkUnicamenteCliente(_direccionCliente);
        _;
    }
    modifier unicamenteAseguradora(address _direccionCliente){
        require(owner == _direccionCliente, "No autorizada");
        _;
    }
    // Permite realizar la operacion a la aseguradora o el cliente
    modifier EsClienteOaseguradora(address _direccionCliente, address _direccionEntrante){
        require( (mappingClientes[_direccionCliente].autorizado == true && _direccionCliente == _direccionEntrante) || owner == _direccionEntrante,  "Solo compañia de seguros o asegurado");
        _;
    }
    
    // ----------------------------- ESTRUCTURAS -----------------------------

    struct Cliente {
        address direccionCliente;
        bool autorizado;
        address direccionContrato;
    }
    struct ServicioAseguradora {
        string nombreServicio;
        uint precio;
        bool estadoServicio; // Disponible, No disponible, En espera
    }
    struct Laboratorio {
        address direccionContratoLaboratorio;
        bool laboratorioValidad;
    }
    
    // ----------------------------- CONSTRUCTOR -----------------------------

    constructor() public {
        token = new ERC20Basic(100);
        insurance = address(this); 
        owner = msg.sender;
    }
    
    // ----------------------------- FUNCIONES -----------------------------

    function checkUnicamenteCliente(address _direccionCliente) public view {
        require(mappingClientes[_direccionCliente].autorizado == true, "No autorizada");
    }
    
    function crearLaboratorio() public{
        direccionesLaboratorios.push(msg.sender);
        address direccionLaboratorio = address(new ContratoLaboratorio(msg.sender,insurance));
        //Laboratorio memory lab = Laboratorio(direccionLaboratorio,true);
        mappingLaboratorios[msg.sender] = Laboratorio(direccionLaboratorio,true);
        emit EventoLaboratorioCreado(msg.sender,direccionLaboratorio);
    }
    
    function crearContratoCliente() public{
        direccionesClientes.push(msg.sender);
        address direccionContratoCliente = address(new Seguro(msg.sender, token, insurance, owner));
        mappingClientes[msg.sender] = Cliente(msg.sender,true,direccionContratoCliente);
        emit EventoClienteCreado(msg.sender,direccionContratoCliente);
    }
    
    function laboratorios() public view unicamenteAseguradora(msg.sender) returns (address [] memory){
        return direccionesLaboratorios;
    }
    
    function clientes() public view unicamenteAseguradora(msg.sender) returns (address [] memory){
        return direccionesClientes;
    }
    
    function consultarHistorialCliente(address _direccionCliente, address _direccionConsultar) public view EsClienteOaseguradora(_direccionCliente, _direccionConsultar) returns (string memory){
        string memory historial = "";
        address direccionContratoCliente = mappingClientes[_direccionCliente].direccionContrato;
        for(uint i = 0; i<nombreServicios.length;i++){
            if(mappingServicios[nombreServicios[i]].estadoServicio &&
            Seguro(direccionContratoCliente).estadoServicioCliente(nombreServicios[i]) == true ){
                (string memory nombreServicio, uint precioServicio) = Seguro(direccionContratoCliente).historialCliente(nombreServicios[i]);
                historial = string(abi.encodePacked(historial, "(", nombreServicio, ", ", uint2str(precioServicio), ") -------- " ));
                
            }
        }
        return historial;
    }
    
    function bajaCliente(address _direccionCliente) public unicamenteAseguradora(msg.sender){
        mappingClientes[_direccionCliente].autorizado = false;
        Seguro(mappingClientes[_direccionCliente].direccionContrato).darDeBaja();
        emit EventoBajaCliente(_direccionCliente);
    }
    
    function nuevoServicio(string memory _nombreServicio, uint _precioServicio) public unicamenteAseguradora(msg.sender){
        nombreServicios.push(_nombreServicio);
        mappingServicios[_nombreServicio] = ServicioAseguradora(_nombreServicio, _precioServicio, true);
        emit EventoServicioCreado(_nombreServicio,_precioServicio);
    }
    
    function bajaServicio(string memory _nombreServicio) public unicamenteAseguradora(msg.sender){
        require(servicioEstado(_nombreServicio) == true, "No se ha dado de alta este servicio");
        mappingServicios[_nombreServicio].estadoServicio = false;
        emit EventoBajaServicio(_nombreServicio);
    }
    
    function servicioEstado(string memory _nombreServicio) public view returns(bool){
        return mappingServicios[_nombreServicio].estadoServicio;
    }
    
    function precioServicio(string memory _nombreServicio) public view returns(uint){
        require(servicioEstado(_nombreServicio) == true, "No se ha dado de alta este servicio");
        return mappingServicios[_nombreServicio].precio;
    }
    
    function consultarServiciosActivos() public view returns(string[] memory){
        string[] memory serviciosActivos = new string[](nombreServicios.length);
        uint contador = 0;
        for(uint i = 0; i<nombreServicios.length; i++){
            if(servicioEstado(nombreServicios[i]) == true){
                serviciosActivos[i] = nombreServicios[i];
                contador++;
            }
        }
        return serviciosActivos;
    }
    
    function comprarTokens(address _cliente, uint _cantidad) public payable unicamenteCliente(_cliente){
        uint balance = balanceOf();
        require(balance >= _cantidad, "Compra un numero de tokens inferior");
        require(_cantidad > 0, "introduce una cantidad positiva");
        token.transfer(msg.sender,_cantidad);
        emit EventoTokenComprado(_cantidad);
    }
    
     function balanceOf() public view returns(uint256 tokens){
            return (token.balanceOf(address(this)));
        }
    
    function generarTokens(uint _numTokens) public unicamenteAseguradora(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
}

contract Seguro is OperacionesBasicas {
    
    // ----------------------------- VARIABLES -----------------------------

    enum Estado {alta,baja}
    Owner propietario;
    mapping(string => ServiciosSolicitados) mappingHistorialCliente;
    ServiciosSolicitadosLaboratorio[] arrayHistorialClienteLaboratorio;
    
    // ----------------------------- EVENTOS -----------------------------

    event EventoSelfDestruct(address direccion);
    event EventoDevolverTokens(address direccion, uint cantidad);
    event EventoServicioPagado(address asegurado, string servicio, uint256 coste);
    event EventoPeticionServicioLab(address asegurado, address laboratorio, string servicio);
    
    // ----------------------------- MODIFICADORES -----------------------------
    
    modifier UnicamentePropietario(address _direccion){
        require(_direccion == propietario.direccionPropietario, "No eres el asegurado de la poliza");
        _;
    }

    // ----------------------------- ESTRUCTURAS -----------------------------

    struct Owner {
        address direccionPropietario;
        uint saldoPropietario;
        Estado estado;
        IERC20 tokens;
        address insurance;
        address payable aseguradora;
    }
    
    struct ServiciosSolicitados{
        string nombreServicio;
        uint precioServicio;
        bool estadoServicio;
    }
    
    struct ServiciosSolicitadosLaboratorio{
        string nombreServicio;
        uint precioServicio;
        address direccionLaboratorio;
    }
    
    // ----------------------------- CONSTRUCTOR -----------------------------

    constructor(address _owner, IERC20 _token, address _insurance, address payable _aseguradora) public{
        propietario.direccionPropietario = _owner;
        propietario.saldoPropietario = 0;
        propietario.estado = Estado.alta;
        propietario.tokens = _token;
        propietario.insurance = _insurance;
        propietario.aseguradora = _aseguradora;
    }
    
    // ----------------------------- FUNCIONES -----------------------------

 // Funcion para ver el historial de los servicios de la aseguradora que ha consumido el asegurado
    function historialAseguradora() public view UnicamentePropietario(msg.sender) returns(string memory) {
        return InsuranceFactory(propietario.insurance).consultarHistorialCliente(msg.sender, msg.sender);
    }
    
    
    function historialClienteLaboratorio() public view returns(ServiciosSolicitadosLaboratorio[] memory){
        return arrayHistorialClienteLaboratorio;
    }
    
    function historialCliente(string memory _nombreServicio) public view returns (string memory servicio, uint256 precio){
        return(mappingHistorialCliente[_nombreServicio].nombreServicio, mappingHistorialCliente[_nombreServicio].precioServicio);
    }
    
    function estadoServicioCliente(string memory _nombreServicio) public view returns(bool){
        return(mappingHistorialCliente[_nombreServicio].estadoServicio);
    }
    
    function darDeBaja() public UnicamentePropietario(msg.sender){
        emit EventoSelfDestruct(msg.sender);
        selfdestruct(msg.sender);
    }
    
    function compraTokens(uint _cantidad) payable public UnicamentePropietario(msg.sender){
        require(_cantidad > 0, "introduce un valor positivo");
        uint costeToken = calcularPrecioTokens(_cantidad);
        require(msg.value >= costeToken, "No tienes suficientes ethers");
        uint returnValue = msg.value - costeToken;
        msg.sender.transfer(returnValue);
        InsuranceFactory(propietario.insurance).comprarTokens(msg.sender,_cantidad);
        
    }
    
    function balanceOf() public view UnicamentePropietario(msg.sender) returns(uint256){
        return propietario.tokens.balanceOf(address(this));
    }
    
    function devolverTokens(uint _numTokens) public UnicamentePropietario(msg.sender){
        require(_numTokens > 0, "El numero debe ser mayor que 0");
        require(_numTokens <= balanceOf(), "No tienes tokens suficientes para devolverlos");
        propietario.tokens.transfer(propietario.aseguradora, _numTokens);
        msg.sender.transfer(calcularPrecioTokens(_numTokens));
        emit EventoDevolverTokens(msg.sender, _numTokens);
    }
    
    function peticionServicio(string memory _servicio) public UnicamentePropietario(msg.sender){
        require(InsuranceFactory(propietario.insurance).servicioEstado(_servicio) == true, "Servicio no disponible");
        uint256 pagoTokens = InsuranceFactory(propietario.insurance).precioServicio(_servicio);
        require(pagoTokens <= balanceOf(), "No tienes tokens suficientes");
        propietario.tokens.transfer(propietario.aseguradora,pagoTokens);
        mappingHistorialCliente[_servicio] = ServiciosSolicitados(_servicio,pagoTokens,true);
        emit EventoServicioPagado(msg.sender, _servicio, pagoTokens);
    }
    
    function peticionServicioLab(address direccionLab, string memory _servicio) public payable UnicamentePropietario(msg.sender){
        ContratoLaboratorio contratoLab = ContratoLaboratorio(direccionLab);
        require(msg.value == contratoLab.consultarPrecioServicio(_servicio) * 1 ether, "Operacion no valida");
        contratoLab.darServicio(msg.sender, _servicio);
        payable(contratoLab.direccionLaboratorio()).transfer(contratoLab.consultarPrecioServicio(_servicio) * 1 ether );
        arrayHistorialClienteLaboratorio.push(ServiciosSolicitadosLaboratorio(_servicio,contratoLab.consultarPrecioServicio(_servicio), direccionLab));
        emit EventoPeticionServicioLab(msg.sender,direccionLab,_servicio);
    }
    
}

contract ContratoLaboratorio is OperacionesBasicas {
    
    // ----------------------------- VARIABLES -----------------------------

    address public direccionLaboratorio;
    address contratoAseguradora;
    address[] public peticionesServicios;
    
    string[] nombreServiciosLab;
    
    mapping(address => ResultadoServicio) mappingResultadoServicios;
    mapping (address => string) public mappingServiciosSolicitados;
    mapping(string => ServicioLab) public mappingServiciosLab;
    
    // ----------------------------- ESTRUCTURAS -----------------------------

    struct ResultadoServicio{
        string diagnostico_servicio;
        string codigo_IPFS;
    }
    
    struct ServicioLab{
        string nombreServicio;
        uint precioServicio;
        bool funcionamiento;
    }
    
    // ----------------------------- EVENTOS -----------------------------

    event EventoServicioFuncionando(string,uint);
    event EventoDarServicio(address,string);
    
    
    // ----------------------------- MODIFICADORES -----------------------------

    modifier UnicamenteLaboratorio(address direccion){
        require(direccionLaboratorio == direccion, "No tienes permisos");
        _;
    }
    
    // ----------------------------- CONSTRUCTOR -----------------------------

    constructor(address _direccionLaboratorio, address _contratoAseguradora) public {
        direccionLaboratorio = _direccionLaboratorio;
        contratoAseguradora = _contratoAseguradora;
    }
    
    // ----------------------------- FUNCIONES -----------------------------

    function nuevoServicio(string memory _nombreServicio, uint _precio) public UnicamenteLaboratorio(msg.sender){
        mappingServiciosLab[_nombreServicio] = ServicioLab(_nombreServicio, _precio, true);
        nombreServiciosLab.push(_nombreServicio);
        emit EventoServicioFuncionando(_nombreServicio,_precio);
    }
    
    function consultarServicios() public view returns(string[] memory){
        return nombreServiciosLab;
    }
    
    function consultarPrecioServicio(string memory _servicio) public view returns(uint) {
        return mappingServiciosLab[_servicio].precioServicio;
    }
    
    function darServicio(address cliente, string memory _servicio) public {
        InsuranceFactory IF = InsuranceFactory(contratoAseguradora);
        IF.checkUnicamenteCliente(cliente);
        require(mappingServiciosLab[_servicio].funcionamiento,"Servicio no activo");
        mappingServiciosSolicitados[cliente] = _servicio;
        peticionesServicios.push(cliente);
        emit EventoDarServicio(cliente,_servicio);
    }
    
    function darResultados(address _cliente, string memory _diagnostico, string memory _codigoIPFS) public UnicamenteLaboratorio(msg.sender) {
        mappingResultadoServicios[_cliente] = ResultadoServicio(_diagnostico, _codigoIPFS);
    }
    
    function visualizarResultados(address _cliente) public view returns (string memory _diagnostico, string memory _codigo_IPFS){
        _diagnostico = mappingResultadoServicios[_cliente].diagnostico_servicio;
        _codigo_IPFS = mappingResultadoServicios[_cliente].codigo_IPFS;
    }
    
}

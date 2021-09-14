pragma solidity >= 0.7.0 < 0.9.0;
pragma experimental ABIEncoderV2;

contract Oms{
    
    // Dirección OMS dueño del contrato
    address public OMS;
    
    // Constructor del contrado
    constructor(){
        OMS = msg.sender;
    }
    
    // Mapping para relacionar los centros de salud (address) con la validez del sistema de gestion
    mapping(address => bool) validacionCentrosSalud;
    
    // Relacionar una direccion de un centro de salud con su contrato
    mapping(address => address) public centroSaludContrato;
    
    // Array de direcciones de los contratos de los centros de salud validados
    address[] public direcciones_contratos_salud;
 
    // Array para centros que solicitan acceso
    address[] solicitudes;
 
    // Eventos a emitir
    event NuevoCentroValidado(address);
    event NuevoContrato(address,address); // 1- direccion contrato, 2.- direccion emisor centro salud
    event solicitudAcceso(address);
    
    // Modificadores
    modifier soloAdministrador(address direccion){
        require(direccion == OMS, "No tienes permisos");
        _;
    }
    
    // Funcion para solicitar acceso al sistema medico
    function solicitarAcceso() public {
        // Guardamos la solicitud de la direccion
        solicitudes.push(msg.sender);
        // Emitimos el evento
        emit solicitudAcceso(msg.sender);
    }
    
    function visualizarSolicitudes() public view soloAdministrador(msg.sender) returns(address [] memory){
        return solicitudes;
    }
    
    // Funcion para validar nuevos centros de salud que puedan autogestionarse -> soloAdministrador
    function validarCentroSalud(address _direccion) public soloAdministrador(msg.sender){
        // Asignacion del estado de validez al centro de salud
        validacionCentrosSalud[_direccion] = true;
        emit NuevoCentroValidado(_direccion);
    }
    
    // Funcion que permita crear un contrato inteligente de un centro de salud
    function FactoryCentroSalud() public {
      // Filtrado para que unicamente los centros de salud validado puedan ejecutar esta Funcion
      require(validacionCentrosSalud[msg.sender] == true, "No tienes permisos");
      // Generar un smart contract
      address nuevoCentro = address(new CentroSalud(msg.sender));
      // Almacenamos la direccion del contrato en el array
      direcciones_contratos_salud.push(nuevoCentro);
      // Relacion entre el centro de salud y su contrato
      centroSaludContrato[msg.sender] = nuevoCentro;
      // Emitimos evento de nuevo contrato
      emit NuevoContrato(nuevoCentro,msg.sender);
    }
    
}

// Contrato autogestionable por el centro de salud

contract CentroSalud{
    
    address public direccionContrato;
    address public DireccionCentroSalud;
    
    constructor(address _direccion){
     DireccionCentroSalud = _direccion;
     direccionContrato = address(this);   
    }
    
    // Mapping que permita relacionar la ID de una persona con una prueba COVID
    //mapping(bytes32 => bool) resultadoCOVID;// Resultado COVID
    // Mapping para relacionar el hash de la prueba con el codigo IPFS
    //mapping(bytes32 => string) resultadoCOVID_IPFS;
    // Mapping para relacionar el hash de la persona con los resultados (diagnostico,codigo IPFS)
    mapping(bytes32 => Resultados) resultadosCOVID;
    
    struct Resultados{
        bool diagnostico;
        string codigoIPFS;
    }
    
    // Eventos
    event nuevoResultado(bool,string);
    
    // Filtrar las funciones a ejecutar en el centro de salud
    modifier soloCentroSalud(address _direccion){
        require(_direccion == DireccionCentroSalud, "No tienes permisos");
        _;
    }
    
    // Funcion para emitir un resultado de una prueba de COVID
    // Formato de los campos de entrada: | 1235X | true | QmtqtoeFG43tGko6YppfaafvhkyppFkgsg.....
    function resultadosPruebaCovid(string memory _idPersona, bool _resultadoCOVID, string memory _codigoIPFS) public soloCentroSalud(msg.sender){
        // Hash de la identificacion de la persona
        bytes32 hashIDpersona = keccak256(abi.encodePacked(_idPersona));
        
        // Relacion entre el hash de la persona y el resultado de la prueba COVID
        //resultadoCOVID[hashIDpersona] = _resultadoCOVID;
        //resultadoCOVID_IPFS[hashIDpersona] = codigoIPFS;
        
        // Relacion de persona con los resultados 
        resultadosCOVID[hashIDpersona] = Resultados(_resultadoCOVID,_codigoIPFS);
        // Emitimos evento de nuevo resultado
        emit nuevoResultado(_resultadoCOVID,_codigoIPFS);
    }
    
    // Funcion que permita la visualizacion de los resultados
    function visualizarResultados(string memory _idPersona) public view returns(string memory, string memory){
        // Hash de la identificacion de la persona
        bytes32 hashIDpersona = keccak256(abi.encodePacked(_idPersona));
        // Retorno de un booleano como un string
        string memory resultadoPrueba;
        
        if(resultadosCOVID[hashIDpersona].diagnostico == true){
            resultadoPrueba = "Positivo";
        }else{
            resultadoPrueba = "Negativo";
        }
        return (resultadoPrueba,resultadosCOVID[hashIDpersona].codigoIPFS);
    }
    
}
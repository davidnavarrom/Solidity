// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;



contract Notas{
    
    //Dirección del profesor
    address public profesor;
    
    //constructor
    constructor() public{
        profesor = msg.sender;
    }
    
    // Mapping para reelacionar el hash de la identidad del alumno con su nota del examen
    mapping(bytes32 => uint) notas;
    
    // Array de los alumnos que pidan revisiones de examen
    string[] revisiones;
    
    // Eventos
    event alumno_evaluado(bytes32,uint);
    event evento_revision(string);
    

    // Funcion en la que el profesor publica la nota de un alumno_evaluado
    function evaluar(string memory _idAlumno, uint nota) public UnicamenteProfesor(msg.sender){
        //hash identificacion del alumno_evaluado
        bytes32 hash_idAlumno = keccak256(abi.encodePacked(_idAlumno));
        //Relacion entre el hash de la identificacion del alumno y su nota
        notas[hash_idAlumno] = nota;
        //Emision del evento
        emit alumno_evaluado(hash_idAlumno, nota);
    }
    
    modifier UnicamenteProfesor(address _direccion){
        //Requiere que la direccion sea el owner del contrato
        require(_direccion == profesor, "No tienes permisos para ejecutar esta funcion");
        _;
    }
    
    // Funcion para ver las notas de un alumno
    function verNotas(string memory _idAlumno) public view returns (uint){
        // Hash identificacion alumno
        bytes32 hash_idAlumno = keccak256(abi.encodePacked(_idAlumno));
        return notas[hash_idAlumno];
    }
    
    
    function revisarNotas(string memory _idAlumno) public {
        // Almacenamos la identidad del alumno en un array
        revisiones.push(_idAlumno);
        emit evento_revision(_idAlumno);
    }
    
    // Funcion para ver los alumnos que han solicitado revisar el examen
    function verRevisiones() public view UnicamenteProfesor(msg.sender) returns(string[] memory ){
        // Devolvemos las identidades de los alumnos
        return revisiones;
    }
    
}
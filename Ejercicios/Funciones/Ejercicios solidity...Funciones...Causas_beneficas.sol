pragma solidity >= 0.4.4 < 0.7.0;

contract Causas_beneficas{
    
    
    struct Causa{
        uint id;
        string name;
        uint precio_objetivo;
        uint cantidad_recaudada;
    }
    
    uint contador_causas = 0;
    mapping (string => Causa) public causaMap ;
    
    // Permite dar de alta una nueva causa
    function nuevaCausa(string memory _name, uint _precio_objetivo) public payable{
        contador_causas = contador_causas++;
        Causa memory causa = Causa(contador_causas,_name,_precio_objetivo,0);
        causaMap[_name] = causa;
    }
    
    // Permite donar a una causa
    function donarCausa(string memory nombre, uint cantidad) public returns(bool){
        
        bool donacionRealizada = false;
        
        //Si la cantidad recaudada es superior al precio objetivo, retornar false porque ya no se puede donar a esta causa.
        if(objetivoCumplido(nombre,cantidad)){
            Causa storage causa = causaMap[nombre];
            causa.cantidad_recaudada = causa.cantidad_recaudada + cantidad;
            causaMap[nombre] = causa;
            donacionRealizada =  true;
        }
        
        
        return donacionRealizada;
        
    }
    
    // Devuelve true si podemos donar a una causa y false si no se puede
    function objetivoCumplido(string memory _name, uint _cantidad) private view returns (bool) {
        bool objetivocompletado = false;
        Causa memory causa = causaMap[_name]; 
        if(causa.precio_objetivo >= (causa.cantidad_recaudada + _cantidad)){
            objetivocompletado = true;
        }else{
            objetivocompletado = false;
        }
        
        return objetivocompletado;
    }
    
    
    // Funcion que nos dice si hemos llegado al precio objetivocompletado
    function comprobarPrecioObjetivo(string memory _nombre) public view returns(bool,uint){
        
        bool limite_alcanzado = false;
        Causa memory causa = causaMap[_nombre];
        if(causa.cantidad_recaudada >= causa.precio_objetivo){
            limite_alcanzado = true;
        }
        return (limite_alcanzado,causa.cantidad_recaudada);
    }
    
}
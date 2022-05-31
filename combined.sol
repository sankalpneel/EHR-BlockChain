pragma solidity >=0.4.22 <0.9.0;

/**
 * @title Hospital Registration
 * @dev Store & retreive Hospital details
 */

//owner,hospital,hospital,doctor

contract Hospital {
    mapping(address => hospital) hospitallist;
    mapping(uint256 => address) hospitalfinder;

    struct hospital {
        string hospital_name;
        uint256 hospital_id;
        string hospital_address;
        string hospital_spec;
        address hospital_block_address;
        bool hospital_acceess;
    }
    hospital h;

    //Doctors

    mapping(address => doctor) doctorlist;
    mapping(uint256 => address) doctorfinder;

    struct doctor {
        string doctor_name;
        string doctor_specialisation;
        uint256 doctor_ph_no;
        string doctor_address;
        bool doctor_acceess;
        address doctor_block_address;
    }
    doctor d;

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    // modifier to give access only to hospital
    modifier isHospital() {
        bool hasAccess = hospitallist[msg.sender].hospital_acceess;

        require(hasAccess || msg.sender == owner, "Access is not allowed");

        _;
    }

    //HOSPITAL FUNCTIONSSSSSS

    /**
     * @dev Store hospital details
     * @param _hospital_id hospital registration id
     * @param _hospital_block_address hospital block address
     * @param _hospital_name name of hospital
     * @param _hospital_spec hospital specialisation
     * @param _hospital_address hospital address
     * */
    function store_hospital_details(
        uint256 _hospital_id,
        address _hospital_block_address,
        string memory _hospital_name,
        string memory _hospital_address,
        string memory _hospital_spec
    ) public isHospital {
        h.hospital_name = _hospital_name;
        h.hospital_id = _hospital_id;
        h.hospital_address = _hospital_address;
        h.hospital_spec = _hospital_spec;
        h.hospital_acceess = true;
        h.hospital_block_address = _hospital_block_address;

        hospitalfinder[_hospital_id] = _hospital_block_address;
        hospitallist[_hospital_block_address] = h;
    }

    /**
     * @dev Retreive hospital details
     * @param _hospital_id hospital registration id
     * */
    function retreive_hospital_details(uint256 _hospital_id)
        public
        view
        returns (
            string memory,
            string memory,
            string memory
        )
    {
        hospital memory hp = hospitallist[hospitalfinder[_hospital_id]];

        return (hp.hospital_name, hp.hospital_address, hp.hospital_spec);
    }

    //Doctor FUNCTIONSSSSSS

    /**
     * @dev Store doctor details
     * @param doctor_id doctor id
     * @param _doctor_block_address doctor block address
     * @param _doctor_name name of doctor
     * @param _doctor_specialisation specialisation of doctor
     * @param _doctor_ph_no doctor phone number
     */
    function store_doctor_details(
        uint16 doctor_id,
        address _doctor_block_address,
        string memory _doctor_name,
        string memory _doctor_specialisation,
        uint256 _doctor_ph_no,
        string memory _doctor_address
    ) public isHospital {
        d.doctor_name = _doctor_name;
        d.doctor_specialisation = _doctor_specialisation;
        d.doctor_ph_no = _doctor_ph_no;
        d.doctor_address = _doctor_address;
        d.doctor_block_address = _doctor_block_address;
        d.doctor_acceess = true;

        doctorlist[_doctor_block_address] = d;
        doctorfinder[doctor_id] = _doctor_block_address;
    }

    /**
     * @dev Retreive doctor details
     * @param doctor_id doctor id
     * */
    function retreive_doctor_details(uint16 doctor_id)
        public
        view
        returns (
            string memory,
            string memory,
            uint256,
            string memory
        )
    {
        doctor memory doc = doctorlist[doctorfinder[doctor_id]];

        return (
            doc.doctor_name,
            doc.doctor_specialisation,
            doc.doctor_ph_no,
            doc.doctor_address
        );
    }

    //Patient
    mapping(uint256 => patient) patientlist;
    mapping(uint256 => attendant) attendantlist;
    // modifier to give access only to hospital,doctor,patient himself
    modifier PatientChanger(address pblock) {
        require(
            msg.sender == owner ||
                msg.sender == pblock ||
                hospitallist[msg.sender].hospital_acceess,
            "Access is not allowed"
        );

        _;
    }

    modifier PatientDetailsFind(uint256 id) {
        bool isPatient = patientlist[id].patient_block_address == msg.sender;
        bool isaHospital = hospitallist[msg.sender].hospital_acceess;
        bool isDoctor = doctorlist[msg.sender].doctor_acceess;

        require(
            isPatient || isaHospital || isDoctor || msg.sender == owner,
            "Access is not allowed"
        );

        _;
    }

    //Patient

    struct patient {
        string patient_name;
        uint256 age;
        string gender;
        string height;
        uint256 weight;
        uint256 phone_no;
        uint256 date;
        uint256 doctor_id;
        uint256 hospital_id;
        address patient_block_address;
        string email_id;
        string patient_address;
    }
    patient p;

    struct attendant {
        uint256 patient_id;
        string attendant_name;
        string attendant_relation;
        uint256 attendant_phn_no;
    }
    attendant a;

    /**
     * @dev Store patient details
     * @param patient_id patient id
     * @param _patient_name patient name
     * @param _age age
     * @param _gender gender
     * @param _height height
     * @param _weight weight
     * @param _patient_address address
     * @param _phone_no phone number
     * @param _email_id mail id
     * @param _date date
     */
    function store_patient_details(
        uint256 patient_id,
        address pblock,
        string memory _patient_name,
        uint256 _age,
        string memory _gender,
        string memory _height,
        uint256 _weight,
        string memory _patient_address,
        uint256 _phone_no,
        string memory _email_id,
        uint256 _date
    ) public PatientChanger(pblock) {
        p.patient_name = _patient_name;
        p.age = _age;
        p.gender = _gender;
        p.height = _height;
        p.weight = _weight;
        p.phone_no = _phone_no;
        p.patient_address = _patient_address;
        p.email_id = _email_id;
        p.date = _date;
        p.patient_block_address = pblock;

        patientlist[patient_id] = p;
    }

    /**
     * @dev Store attendant details
     * @param patient_id patient id
     * @param _attendant_name name of attendant
     * @param _attendant_relation relation to patient
     * @param _attendant_phn_no phone no
     * */
    function store_attendant_details(
        uint256 patient_id,
        string memory _attendant_name,
        string memory _attendant_relation,
        uint256 _attendant_phn_no
    ) public {
        require(
            msg.sender == owner ||
                msg.sender == patientlist[patient_id].patient_block_address ||
                hospitallist[msg.sender].hospital_acceess ||
                doctorlist[msg.sender].doctor_acceess,
            "Access is not allowed"
        );
        a.patient_id = patient_id;
        a.attendant_name = _attendant_name;
        a.attendant_relation = _attendant_relation;
        a.attendant_phn_no = _attendant_phn_no;

        attendantlist[patient_id] = a;
    }

    /**
     * @dev Retreive patient details
     * @param patient_id patient id
     * */
    function retreive_patient_details(uint256 patient_id)
        public
        view
        returns (
            string memory,
            uint256,
            string memory,
            string memory,
            uint256,
            string memory,
            uint256,
            string memory,
            uint256
        )
    {
        //require( msg.sender == patientlist[patient_id].patient_block_address || hospitallist[msg.sender].hospital_acceess || doctorlist[msg.sender].doctor_acceess , "Access is not allowed");
        require(
            msg.sender == owner ||
                msg.sender == patientlist[patient_id].patient_block_address ||
                hospitallist[msg.sender].hospital_acceess ||
                doctorlist[msg.sender].doctor_acceess,
            "Access is not allowed"
        );
        patient memory p = patientlist[patient_id];

        return (
            p.patient_name,
            p.age,
            p.gender,
            p.height,
            p.weight,
            p.patient_address,
            p.phone_no,
            p.email_id,
            p.date
        );
    }

    /**
     * @dev Retreive attendant details
     * @param patient_id patient id
     * */
    function retreive_attendant_details(uint256 patient_id)
        public
        view
        returns (
            string memory,
            string memory,
            uint256
        )
    {
        require(
            msg.sender == owner ||
                msg.sender == patientlist[patient_id].patient_block_address ||
                hospitallist[msg.sender].hospital_acceess ||
                doctorlist[msg.sender].doctor_acceess,
            "Access is not allowed"
        );
        attendant memory a = attendantlist[patient_id];

        return (a.attendant_name, a.attendant_relation, a.attendant_phn_no);
    }
}

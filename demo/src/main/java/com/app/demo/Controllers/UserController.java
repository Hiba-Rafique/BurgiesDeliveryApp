package com.app.demo.Controllers;

import com.app.demo.DTOs.LoginRequest;
import com.app.demo.models.Role;
import com.app.demo.models.User;
import com.app.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userrepository;

    @Autowired
    public UserController(UserRepository userrepository) {
        this.userrepository = userrepository;
    }

    @PostMapping("/signup")
    public ResponseEntity<String> registerUser(@RequestBody User user) {
        if (userrepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("A user with this email already exists");
        }

        user.setRole(Role.CUSTOMER);
        userrepository.save(user);

        return ResponseEntity.status(HttpStatus.CREATED)  //sends codes that can be used as conditions in flutter!! eg if code==200 then userdashboard() page
                .body("Registration successful");
    }


    @PostMapping("/login")
    public ResponseEntity<String> loginUser(@RequestBody LoginRequest login) {
        User storedUser = userrepository.findByEmail(login.getEmail()).orElse(null);

        if (storedUser == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User with this email doesn't exist");
        }

        if (login.getPassword().equals(storedUser.getPassword())) {
            return ResponseEntity.ok("Logged in successfully!");
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid password");
        }
    }

    @GetMapping("/getrole")
    public ResponseEntity<Map<String, String>> getUserRole(@RequestParam String firstname, @RequestParam String lastname) {
        User user = userrepository.findByFirstNameAndLastName(firstname, lastname);
        if (user != null) {
            Map<String, String> response = new HashMap<>();
            response.put("role", user.getRole().name()); // Convert enum to string
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("role", "CUSTOMER"));
    }



    @GetMapping("/api/get-user-details")
    public ResponseEntity<?> getUserDetails(@RequestParam String email) {

        Optional<User> userOptional = userrepository.findByEmail(email);

        if (userOptional.isPresent()) {
            // Return user details as a response
            return ResponseEntity.ok(userOptional.get());
        } else {
            return ResponseEntity.status(404).body("User not found");
        }
    }

}


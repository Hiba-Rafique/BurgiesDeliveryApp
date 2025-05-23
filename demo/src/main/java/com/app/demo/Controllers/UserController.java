package com.app.demo.Controllers;

import com.app.demo.DTOs.LoginRequest;
import com.app.demo.models.*;
import com.app.demo.repository.CustomerRepository;
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

    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;

    @Autowired
    public UserController(UserRepository userRepository, CustomerRepository customerRepository) {
        this.userRepository = userRepository;
        this.customerRepository = customerRepository;
    }

    @PostMapping("/signup")
    public ResponseEntity<String> registerUser(@RequestBody Customer customerData) {
        if (userRepository.findByEmail(customerData.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body("A user with this email already exists");
        }

        customerData.setRole(Role.CUSTOMER); // set role before saving

        // Save customer directly (which also saves user fields)
        customerRepository.save(customerData);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body("Customer registration successful");
    }

    @PostMapping("/login")
    public ResponseEntity<String> loginUser(@RequestBody LoginRequest login) {
        User storedUser = userRepository.findByEmail(login.getEmail()).orElse(null);

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
        User user = userRepository.findByFirstNameAndLastName(firstname, lastname);
        if (user != null) {
            Map<String, String> response = new HashMap<>();
            response.put("role", user.getRole().name());
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("role", "CUSTOMER"));
    }

    @GetMapping("/api/get-user-details")
    public ResponseEntity<?> getUserDetails(@RequestParam String email) {
        Optional<User> userOptional = userRepository.findByEmail(email);

        if (userOptional.isEmpty()) {
            return ResponseEntity.status(404).body("User not found");
        }

        User user = userOptional.get();

        // If user is a Customer, return the Customer entity (with address)
        if (user instanceof Customer) {
            return ResponseEntity.ok((Customer) user);
        }

        // Otherwise, return the User entity as is (without address)
        return ResponseEntity.ok(user);
    }

    @PutMapping("/update-profile/{id}")
    public ResponseEntity<?> updateProfile(@PathVariable Long id, @RequestBody Map<String, String> updates) {
        Optional<User> userOptional = userRepository.findById(id);
        if (userOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }

        User user = userOptional.get();

        // Only allow updates if user is Customer (or you can allow others based on logic)
        if (!(user instanceof Customer)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Only customers can update profile here");
        }

        Customer customer = (Customer) user;

        // Update email if present and not already taken by another user
        if (updates.containsKey("email")) {
            String newEmail = updates.get("email").trim();
            if (!newEmail.isEmpty() && !newEmail.equals(customer.getEmail())) {
                if (userRepository.findByEmail(newEmail).isPresent()) {
                    return ResponseEntity.status(HttpStatus.CONFLICT).body("Email already in use");
                }
                customer.setEmail(newEmail);
            }
        }

        // Update phone number if present
        if (updates.containsKey("phoneNum")) {
            String newPhone = updates.get("phoneNum").trim();
            if (!newPhone.isEmpty()) {
                customer.setPhoneNum(newPhone);
            }
        }

        // Update password if present
        if (updates.containsKey("password")) {
            String newPassword = updates.get("password").trim();
            if (!newPassword.isEmpty()) {
                customer.setPassword(newPassword);
            }
        }

        userRepository.save(customer);

        return ResponseEntity.ok("Profile updated successfully");
    }

}

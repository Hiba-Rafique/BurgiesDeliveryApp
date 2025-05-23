package com.app.demo.Controllers;

import com.app.demo.models.Customer;
import com.app.demo.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/customers")
public class CustomerController {

    @Autowired
    private CustomerRepository customerRepository;

    // PUT endpoint to update customer's address
    @PutMapping("/{id}/address")
    public ResponseEntity<?> updateAddress(
            @PathVariable Long id,
            @RequestBody String newAddress) {

        Optional<Customer> customerOpt = customerRepository.findById(id);
        if (!customerOpt.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Customer customer = customerOpt.get();
        customer.setAddress(newAddress);
        customerRepository.save(customer);

        return ResponseEntity.ok(customer);
    }
}

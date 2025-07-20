package org.springframework.samples.petclinic.customers.web;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.Size;

import java.util.Date;

/**
 * @author mszarlinski@bravurasolutions.com on 2016-12-05.
 */
record PetRequest(int id,
                  @JsonFormat(pattern = "yyyy-MM-dd")
                  Date birthDate,
                  @Size(min = 1)
                  String name,
                  int typeId
) {

}
